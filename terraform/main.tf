# This terraform file creates my Azure infrastructure for the banking project
# I learned terraform to automate this instead of clicking in the Azure portal

# create a resource group to hold everything
resource "azurerm_resource_group" "my_rg" {
  name     = "banking-${var.environment}-rg"
  location = var.location
}

# create a virtual network
resource "azurerm_virtual_network" "my_vnet" {
  name                = "banking-${var.environment}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
}

# create a subnet inside the vnet
resource "azurerm_subnet" "my_subnet" {
  name                 = "banking-subnet"
  resource_group_name  = azurerm_resource_group.my_rg.name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# create a network security group
resource "azurerm_network_security_group" "my_nsg" {
  name                = "banking-${var.environment}-nsg"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name

  # only allow SSH from my IP
  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.my_ip
    destination_address_prefix = "*"
  }
}

# create a virtual machine for transaction processing
resource "azurerm_linux_virtual_machine" "my_vm" {
  name                = "banking-${var.environment}-vm"
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = azurerm_resource_group.my_rg.location
  size                = var.vm_size
  admin_username      = "azureuser"

  network_interface_ids = [azurerm_network_interface.my_nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "my_nic" {
  name                = "banking-nic"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.my_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# create azure sql database
resource "azurerm_mssql_server" "my_sql" {
  name                         = "banking-${var.environment}-sql"
  resource_group_name          = azurerm_resource_group.my_rg.name
  location                     = azurerm_resource_group.my_rg.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = var.sql_password
}

resource "azurerm_mssql_database" "my_db" {
  name      = "transactions"
  server_id = azurerm_mssql_server.my_sql.id
  sku_name  = "S1"
}

# set up an alert when CPU goes above 80%
resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "high-cpu-alert"
  resource_group_name = azurerm_resource_group.my_rg.name
  scopes              = [azurerm_linux_virtual_machine.my_vm.id]
  description         = "Alert me when CPU is too high"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.my_alerts.id
  }
}

resource "azurerm_monitor_action_group" "my_alerts" {
  name                = "devops-alert-group"
  resource_group_name = azurerm_resource_group.my_rg.name
  short_name          = "devopsalrt"

  email_receiver {
    name          = "notify-me"
    email_address = var.alert_email
  }
}
