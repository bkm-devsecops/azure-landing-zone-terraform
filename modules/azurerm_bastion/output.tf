output "bastion_hosts" {
  value = {
    for k, v in azurerm_bastion_host.bastion : k => {
      id   = v.id
      name = v.name
      dns_name = v.dns_name
    }
  }
  description = "Map of created Bastion hosts with IDs and FQDNs"
}