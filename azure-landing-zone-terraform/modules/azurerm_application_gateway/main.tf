resource "azurerm_application_gateway" "agw" {
  for_each = var.application_gateways

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  tags                = each.value.tags

  sku {
    name     = each.value.sku_name
    tier     = each.value.sku_tier
    capacity = each.value.capacity
  }

  gateway_ip_configuration {
    name      = "${each.value.name}-gwip-config"
    subnet_id = each.value.subnet_id
  }

  frontend_port {
    name = "frontend-port-http"
    port = each.value.frontend_port_80
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-public"
    public_ip_address_id = each.value.public_ip_id
  }

  # Backend Pool Configuration
  backend_address_pool {
    name         = "default-backend-pool"
    ip_addresses = each.value.backend_ip_addresses
  }

  # Backend HTTP Settings
  backend_http_settings {
    name                  = "default-http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  # HTTP Listener
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-public"
    frontend_port_name             = "frontend-port-http"
    protocol                       = "Http"
  }

  # Request Routing Rule
  request_routing_rule {
    name                       = "http-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "default-backend-pool"
    backend_http_settings_name = "default-http-settings"
    priority                   = 100
  }
}