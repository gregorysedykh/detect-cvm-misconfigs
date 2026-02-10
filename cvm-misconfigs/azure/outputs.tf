output "public_ip" {
  description = "Public IP of the CVM"
  value       = azurerm_public_ip.this.ip_address
}

output "vm_id" {
  description = "Resource ID of the CVM"
  value       = azurerm_linux_virtual_machine.this.id
}
