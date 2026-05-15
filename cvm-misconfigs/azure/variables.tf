variable "subscription_id" {
  description = "Azure subscription ID to deploy into"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "switzerlandnorth"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "rg-cvm-test"
}

variable "virtual_network_name" {
  description = "Virtual network name"
  type        = string
  default     = "cvm-vnet"
}

variable "virtual_network_address_space" {
  description = "Address space for the VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
  default     = "cvm-subnet"
}

variable "subnet_address_prefixes" {
  description = "Subnet prefixes"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "public_ip_name" {
  description = "Public IP resource name"
  type        = string
  default     = "cvm-pip"
}

variable "public_ip_sku" {
  description = "Public IP SKU"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.public_ip_sku)
    error_message = "public_ip_sku must be Basic or Standard."
  }
}

variable "public_ip_zones" {
  description = "Availability zones for the public IP"
  type        = list(string)
  default     = ["1"]
}

variable "network_security_group_name" {
  description = "Network security group name"
  type        = string
  default     = "cvm-nsg"
}

variable "network_interface_name" {
  description = "Network interface name"
  type        = string
  default     = "cvm-nic"
}

variable "accelerated_networking_enabled" {
  description = "Enable accelerated networking on the NIC"
  type        = bool
  default     = false
}

variable "vm_name" {
  description = "Virtual machine name"
  type        = string
  default     = "cvm-test"
}

variable "vm_size" {
  description = "Virtual machine size"
  type        = string
  default     = "Standard_DC2ads_v5"
}

variable "vm_zone" {
  description = "Availability zone for the VM"
  type        = string
  default     = "1"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
}

variable "secure_boot_enabled" {
  description = "Enable Secure Boot"
  type        = bool
  default     = true
}

variable "vtpm_enabled" {
  description = "Enable vTPM"
  type        = bool
  default     = true
}

variable "os_disk_caching" {
  description = "OS disk caching mode"
  type        = string
  default     = "ReadWrite"
}

variable "os_disk_storage_account_type" {
  description = "OS disk storage account type"
  type        = string
  default     = "Premium_LRS"
}

variable "os_disk_security_encryption_type" {
  description = "OS disk encryption type"
  type        = string
  default     = "DiskWithVMGuestState"
  nullable    = true
}

variable "image_publisher" {
  description = "Image publisher"
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "Image offer"
  type        = string
  default     = "ubuntu-24_04-lts"
}

variable "image_sku" {
  description = "Image SKU"
  type        = string
  default     = "ubuntu-pro-cvm"
}

variable "image_version" {
  description = "Image version"
  type        = string
  default     = "latest"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "key_vault_sku_name" {
  description = "SKU name for the Key Vault"
  type        = string
  default     = "premium"
}

variable "key_vault_purge_protection_enabled" {
  description = "Enable purge protection for the Key Vault"
  type        = bool
  default     = true
}