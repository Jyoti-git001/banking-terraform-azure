# Banking Transaction Processing System — Infrastructure Automation

This project automates Azure infrastructure for a banking transaction system using Terraform and Azure DevOps Pipelines.

## What This Project Does

Instead of manually clicking in the Azure portal to create resources, I used Terraform to write the infrastructure as code. The Azure DevOps pipeline then runs Terraform automatically whenever I push code.

## Tech Stack

| Tool | Purpose |
|---|---|
| Terraform | Create Azure infrastructure as code |
| Azure DevOps | CI/CD pipeline to automate terraform |
| Azure VM | Virtual machine for transaction processing |
| Azure SQL | Database for storing transactions |
| Azure Monitor | Alerts when CPU goes above 80% |
| RBAC | Role based access control for security |
| Git | Version control |

## Key Features

- Infrastructure as Code — all Azure resources defined in Terraform files
- Automated Pipeline — terraform plan runs on every PR, apply runs on merge to main
- RBAC Security — different access levels for Dev, Test and Prod environments
- Azure Monitor Alert — sends email when CPU exceeds 80%
- Environment Isolation — separate resource groups for Dev, Test and Prod

## Pipeline Stages

1. Terraform Plan — runs on every pull request
2. Terraform Apply — runs only on merge to main
3. Validate — checks all resources were created successfully

## Author

Sushree Jyotirmayee Mallick
- LinkedIn: https://linkedin.com/in/sushreejyotirmayee
- GitHub: https://github.com/Jyoti-git001
