output "resource_group_name" {
  description = "Name of the resource group containing the lab resources."
  value       = azurerm_resource_group.lab.name
}

output "virtual_machine_names" {
  description = "Names of the provisioned Linux virtual machines."
  value       = azurerm_linux_virtual_machine.web[*].name
}

output "public_ip_addresses" {
  description = "Static public IP addresses assigned to the web virtual machines."
  value       = azurerm_public_ip.web[*].ip_address
}

output "application_urls" {
  description = "HTTP URLs for the Nginx web application."
  value       = [for public_ip in azurerm_public_ip.web[*].ip_address : "http://${public_ip}"]
}