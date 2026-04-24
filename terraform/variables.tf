# variables I use in my terraform code

variable "environment" {
  description = "which environment - dev, test or prod"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "vm_size" {
  description = "size of the virtual machine"
  type        = string
  default     = "Standard_B2s"
}

variable "my_ip" {
  description = "my IP address for SSH access"
  type        = string
}

variable "sql_password" {
  description = "password for sql server"
  type        = string
  sensitive   = true   # this hides it from logs
}

variable "alert_email" {
  description = "email to receive alerts"
  type        = string
}
