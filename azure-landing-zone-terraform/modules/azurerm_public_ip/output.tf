output "public_ips" {
  value = {
    for k, v in azurerm_public_ip.pip : k => {
      id         = v.id
      name       = v.name
      ip_address = v.ip_address
      fqdn       = v.fqdn
    }
  }
  description = "Map of created Public IPs with their assigned IP addresses and FQDNs"
}