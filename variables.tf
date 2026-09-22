variable "subscription_id" {
  description = "Azure subscription ID used by the AzureRM provider."
  type        = string
}

variable "location" {
  description = "Azure region where the lab resources are deployed."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group that contains the lab resources."
  type        = string
  default     = "rg-cloud-portfolio-dev"
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string
  default     = "vnet-cloud-portfolio-dev"
}

variable "vnet_address_space" {
  description = "Address space assigned to the virtual network."
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "subnet_name" {
  description = "Name of the subnet hosting the virtual machines."
  type        = string
  default     = "snet-web"
}

variable "subnet_address_prefixes" {
  description = "Address prefixes assigned to the web subnet."
  type        = list(string)
  default     = ["10.10.1.0/24"]
}

variable "network_security_group_name" {
  description = "Name of the network security group protecting the web subnet."
  type        = string
  default     = "nsg-web-dev"
}

variable "vm_count" {
  description = "Number of web VMs to deploy. Keep this low to control lab costs."
  type        = number
  default     = 1

  validation {
    condition     = var.vm_count >= 1 && var.vm_count <= 3
    error_message = "vm_count must be between 1 and 3 for this lab."
  }
}

variable "vm_name_prefix" {
  description = "Prefix used to name the web virtual machines."
  type        = string
  default     = "vm-web-dev"
}

variable "network_interface_name_prefix" {
  description = "Prefix used to name the virtual machine network interfaces."
  type        = string
  default     = "nic-web-dev"
}

variable "public_ip_name_prefix" {
  description = "Prefix used to name the static public IP addresses."
  type        = string
  default     = "pip-web-dev"
}

variable "vm_size" {
  description = "Azure VM size. Availability depends on the selected region and subscription."
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Administrator username configured on each Linux VM."
  type        = string
  default     = "azureuser"

  validation {
    condition     = can(regex("^[a-z][a-z0-9_-]{0,31}$", var.admin_username))
    error_message = "admin_username must start with a lowercase letter and contain only lowercase letters, numbers, underscores, or hyphens."
  }
}

variable "ssh_public_key_path" {
  description = "Local path to the public SSH key used for VM authentication."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "Public IPv4 CIDR allowed to connect through SSH, for example 203.0.113.10/32."
  type        = string

  validation {
    condition = (
      can(cidrhost(var.allowed_ssh_cidr, 0)) &&
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/([0-9]|[12][0-9]|3[0-2])$", var.allowed_ssh_cidr)) &&
      var.allowed_ssh_cidr != "0.0.0.0/0"
    )
    error_message = "allowed_ssh_cidr must be an IPv4 CIDR and must not be 0.0.0.0/0."
  }
}

variable "os_disk_size_gb" {
  description = "Size of the Standard_LRS managed OS disk in GiB."
  type        = number
  default     = 30

  validation {
    condition     = var.os_disk_size_gb >= 30
    error_message = "os_disk_size_gb must be at least 30 GiB."
  }
}

variable "tags" {
  description = "Additional tags applied to all supported resources."
  type        = map(string)
  default = {
    environment = "dev"
    managed_by  = "terraform"
    project     = "azure-terraform-01"
  }
}