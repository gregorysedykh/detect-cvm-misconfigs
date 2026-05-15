data "azurerm_client_config" "current" {}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

locals {
  kek_url = azapi_resource.cvm_key.output.properties.keyUriWithVersion
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = var.virtual_network_name
  address_space       = var.virtual_network_address_space
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.subnet_address_prefixes
}

resource "azurerm_public_ip" "this" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = var.public_ip_sku
  zones               = var.public_ip_zones
  tags                = var.tags
}

resource "azurerm_network_security_group" "this" {
  name                = var.network_security_group_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "SSH"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.this.name
}

resource "azurerm_network_interface" "this" {
  name                           = var.network_interface_name
  location                       = azurerm_resource_group.this.location
  resource_group_name            = azurerm_resource_group.this.name
  accelerated_networking_enabled = var.accelerated_networking_enabled
  tags                           = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_linux_virtual_machine" "this" {
  name                = var.vm_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  size                = var.vm_size
  admin_username      = var.admin_username
  zone                = var.vm_zone

  network_interface_ids = [azurerm_network_interface.this.id]

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.cvm.id]
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  os_disk {
    caching                          = var.os_disk_caching
    storage_account_type             = var.os_disk_storage_account_type
    security_encryption_type         = var.os_disk_security_encryption_type
    secure_vm_disk_encryption_set_id = azurerm_disk_encryption_set.this.id
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  secure_boot_enabled = var.secure_boot_enabled
  vtpm_enabled        = var.vtpm_enabled
  tags                = var.tags

  depends_on = [
    azurerm_role_assignment.des_encryption,
    azurerm_role_assignment.cvm_key_release,
    azurerm_role_assignment.cvm_orchestrator_release,
  ]
}

resource "azurerm_key_vault" "this" {
  name                        = "kv-cvm-test-${random_string.suffix.result}"
  location                    = azurerm_resource_group.this.location
  resource_group_name         = azurerm_resource_group.this.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = var.key_vault_sku_name
  
  purge_protection_enabled    = var.key_vault_purge_protection_enabled
  enabled_for_disk_encryption = true
  rbac_authorization_enabled  = true
  
  tags                        = var.tags
}

data "azuread_service_principal" "cvm_orchestrator" {
  client_id = "bf7b6499-ff71-4aa2-97a4-f372087be7f0"
}


resource "azurerm_role_assignment" "cvm_orchestrator_release" {
  principal_id         = data.azuread_service_principal.cvm_orchestrator.object_id
  scope                = azapi_resource.cvm_key.id
  role_definition_name = "Key Vault Crypto Service Release User"
}

resource "azurerm_role_assignment" "des_encryption" {
  principal_id         = azurerm_disk_encryption_set.this.identity[0].principal_id
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
}

resource "azurerm_user_assigned_identity" "cvm" {
  name                = "${var.vm_name}-identity"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_role_assignment" "cvm_key_release" {
  principal_id         = azurerm_user_assigned_identity.cvm.principal_id
  scope                = azapi_resource.cvm_key.id
  role_definition_name = "Key Vault Crypto Service Release User"
}



resource "azurerm_disk_encryption_set" "this" {
  name                = "des"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  key_vault_key_id = local.kek_url

  encryption_type = "ConfidentialVmEncryptedWithCustomerKey"

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_virtual_machine_extension" "guest_attestation" {
  name                       = "GuestAttestation"
  virtual_machine_id         = azurerm_linux_virtual_machine.this.id
  publisher                  = "Microsoft.Azure.Security.LinuxAttestation"
  type                       = "GuestAttestation"
  type_handler_version       = "1.0"
  depends_on = [azurerm_linux_virtual_machine.this]
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true

  settings = <<SETTINGS
  {
    "AttestationConfig": {
      "MaaSettings": {
        "maaEndpoint": "",
        "maaTenantName": "GuestAttestation"
      },
      "AscSettings": {
        "ascReportingEndpoint": "",
        "ascReportingFrequency": ""
      },
      "useCustomToken": "false",
      "disableAlerts": "false"
    }
  }
  SETTINGS
}

data "local_file" "cvm_release_policy" {
  filename = "${path.root}/cvm-release-policy.json"
}

resource "azapi_resource" "cvm_key" {
  type                   = "Microsoft.KeyVault/vaults/keys@2022-07-01"
  name                   = var.vm_name
  parent_id              = azurerm_key_vault.this.id
  response_export_values = ["properties.keyUriWithVersion"]
  body = {
    properties = {
      attributes = {
        enabled    = true
        exportable = true
      }
      keyOps = [
        "encrypt",
        "decrypt",
        "wrapKey",
        "unwrapKey"
      ]
      keySize = 2048
      kty     = "RSA-HSM"
      release_policy = {
        contentType = "application/json; charset=utf-8"
        data = trim(data.local_file.cvm_release_policy.content_base64, "=")
      }
    }
  }
}

resource "azurerm_virtual_machine_extension" "azure_disk_encryption" {
  name                       = "AzureDiskEncryptionForLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.this.id
  type_handler_version       = "1.1"
  publisher                  = "Microsoft.Azure.Security"
  type                       = "AzureDiskEncryptionForLinux"
  auto_upgrade_minor_version = true
  settings                   = <<EOF
{
  "EncryptionOperation": "EnableEncryption",
  "KeyVaultURL": "${azurerm_key_vault.this.vault_uri}",
  "KeyVaultResourceId": "${azurerm_key_vault.this.id}",
  "KeyEncryptionAlgorithm": "RSA-OAEP",
  "VolumeType": "Data",
  "KeyEncryptionKeyURL": "${local.kek_url}",
  "KekVaultResourceId": "${azapi_resource.cvm_key.parent_id}"
}
  EOF
  depends_on = [ azurerm_role_assignment.cvm_key_release ]
}