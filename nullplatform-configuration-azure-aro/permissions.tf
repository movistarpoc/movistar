resource "azurerm_role_assignment" "public_dns_write_permissions" {
  scope                = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${var.public_dns_azure_resource_group_name}/providers/Microsoft.Network/dnsZones/${var.public_scope_domain_name}"
  role_definition_name = "DNS Zone Contributor"
  principal_id         = var.azure_service_principal_object_id
}

resource "azurerm_role_assignment" "private_dns_write_permissions" {
  scope                = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${var.private_dns_azure_resource_group_name}/providers/Microsoft.Network/dnsZones/${var.private_scope_domain_name}"
  role_definition_name = "DNS Zone Contributor"
  principal_id         = var.azure_service_principal_object_id
}