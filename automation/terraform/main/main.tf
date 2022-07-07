
######################## LOAD COMMON COMPONENTS ############################

# resource "random_pet" "rg-name" {
#   prefix    = var.resource_group_name_prefix
# }

# Resource Group
data "azurerm_resource_group" "mgmt" {
  # name      = "${local.resource_prefix}-${random_pet.rg-name.id}"
  name      = local.rg
  #location  = var.resource_group_location
}

# Management Virtual Network
data "azurerm_virtual_network" "mgmtnetwork" {
  name                = local.mgmtVnet
  resource_group_name = data.azurerm_resource_group.mgmt.name
}


#Key Vault
data "azurerm_key_vault" "kv" {
  name                = local.kv
  resource_group_name = data.azurerm_resource_group.mgmt.name
}

################# PUBLIC IP CREATION  ########################

#Public IP
resource "azurerm_public_ip" "pubip" {
  name                = "${local.resource_prefix}-pub-ip"
  location            = data.azurerm_resource_group.mgmt.location
  sku                 = "Basic"
  resource_group_name = data.azurerm_resource_group.mgmt.name
  allocation_method   = "Dynamic"
}

resource "azurerm_public_ip" "appgtwy-pubip" {
  name                = "${local.resource_prefix}-appgtwy-pub-ip"
  location            = data.azurerm_resource_group.mgmt.location
  sku                 = "Basic"
  resource_group_name = data.azurerm_resource_group.mgmt.name
  allocation_method   = "Dynamic"
}

################### LINUX VM CREATION  ###########################

#KV Secret
data "azurerm_key_vault_secret" "linux_vm_password" {
  for_each = var.vm-app
  name         = each.value.password_key
  key_vault_id = "${data.azurerm_key_vault.kv.id}"
}

# VM Subnet
data "azurerm_subnet" "vm_subnet" {
  #for_each = var.vm-app
  name                 = local.promSubnet
  resource_group_name  = data.azurerm_resource_group.mgmt.name
  virtual_network_name = data.azurerm_virtual_network.mgmtnetwork.name
}

resource "azurerm_network_interface" "vm_nic" {
  for_each = var.vm-app
  name                = "${local.resource_prefix}-${each.key}-nic"
  location            = data.azurerm_resource_group.mgmt.location
  resource_group_name = data.azurerm_resource_group.mgmt.name

  ip_configuration {
    name                          = "${local.resource_prefix}-${each.key}-ipconfig"
    #subnet_id                     = data.azurerm_subnet.vm_subnet[each.key].id
    subnet_id                     = data.azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "linux_vm" {
  for_each = var.vm-app
  name                  = "${local.resource_prefix}-${each.key}-vm"
  location              = data.azurerm_resource_group.mgmt.location
  resource_group_name   = data.azurerm_resource_group.mgmt.name
  network_interface_ids = [azurerm_network_interface.vm_nic[each.key].id]
  vm_size               = "Standard_DS1"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${local.resource_prefix}-${each.key}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
#   storage_data_disk {
#    name              = "${var.prefix}-${var.env}-${var.region}-${each.key}-datadisk"
#    managed_disk_type = each.value.managed_disk_type
#    create_option     = "Empty"
#    lun               = 0
#    disk_size_gb      = each.value.disk_size_gb
#  }
  os_profile {
    computer_name  = "${local.resource_prefix}-${each.key}-vm"
    admin_username = each.value.userid
    admin_password = "${data.azurerm_key_vault_secret.linux_vm_password[each.key].value}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment   = var.env
	  location      = var.region
	  customercode  = local.cust_code
	  application   = each.value.application    
  }
}

################### VM SCALESET CREATION   ###########################

#KV Secret
data "azurerm_key_vault_secret" "vmss_password" {
  for_each = var.vmss-app
  name         = each.value.password_key
  key_vault_id = "${data.azurerm_key_vault.kv.id}"
}

#Subnet
data "azurerm_subnet" "vmss_subnet" {
  for_each = var.vmss-app
  name                 = each.value.subnet
  resource_group_name  = data.azurerm_resource_group.mgmt.name
  virtual_network_name = data.azurerm_virtual_network.mgmtnetwork.name
}

resource "azurerm_linux_virtual_machine_scale_set" "mgmt" {
  for_each = var.vmss-app
  name                = "${local.resource_prefix}-${each.key}-vmss"
  resource_group_name = data.azurerm_resource_group.mgmt.name
  location            = data.azurerm_resource_group.mgmt.location
  #zones               = each.value.zones
  sku                 = each.value.vm_size
  instances           = each.value.instance_count
  admin_username      = each.value.userid
  admin_password      = "${data.azurerm_key_vault_secret.vmss_password[each.key].value}"
  disable_password_authentication = false
  
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = each.value.sku
    version   = "latest"
  }
  os_disk {
    storage_account_type = each.value.managed_disk_type
    caching              = "ReadWrite"
  }
#   data_disk {
#     storage_account_type = each.value.managed_disk_type
#     create_option     = "Empty"
#     lun               = 0
#     disk_size_gb      = each.value.disk_size_gb
# 	caching              = "ReadWrite"
#  }  
  network_interface {
    name    = "${local.resource_prefix}-${each.key}-nic"
    primary = true
    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = data.azurerm_subnet.vmss_subnet[each.key].id
	    #application_gateway_backend_address_pool_ids = each.key == "grafana" ? ["${azurerm_application_gateway.main.id}/backendAddressPools/${var.prefix}-${var.env}-${var.region}-beap"] : []
    }
  }
  tags = {
      environment   = var.env
	    location      = var.region
	    customercode  = local.cust_code
	    application   = each.value.application 
  }
}

################### LOAD BALANCER CREATION   ###########################

# data "azurerm_subnet" "lb_subnet" {
#   name                 = local.lb_subnet
#   resource_group_name  = data.azurerm_resource_group.mgmt.name
#   virtual_network_name = data.azurerm_virtual_network.mgmtnetwork.name
# }

# resource "azurerm_lb" "main" {
#   name                = "${local.resource_prefix}-lb"
#   location            = data.azurerm_resource_group.mgmt.location
#   resource_group_name = data.azurerm_resource_group.mgmt.name
#   sku                 = "Basic"
  
#   frontend_ip_configuration {
#     name = "${local.resource_prefix}-lb-frontend"
# 	  #subnet_id = data.azurerm_subnet.lb_subnet.id
# 	  #private_ip_address_allocation = "Dynamic"
# 	  #private_ip_address_version = "IPv4"
#     public_ip_address_id = azurerm_public_ip.pubip.id
#   }
#   tags = {
#       environment   = var.env
# 	    location      = var.region
# 	    #customercode  = local.cust_code
#   }
# }

# resource "azurerm_lb_backend_address_pool" "main" {
#   loadbalancer_id     = azurerm_lb.main.id
#   name                = "${local.resource_prefix}-beap"
# }

# resource "azurerm_lb_probe" "main" {
#   resource_group_name = data.azurerm_resource_group.mgmt.name
#   loadbalancer_id     = azurerm_lb.main.id
#   name                = "${local.resource_prefix}-lb-probe"
#   port                = 80
#   protocol            = "Tcp"
#   interval_in_seconds = 5
#   number_of_probes    = 2
# }

# resource "azurerm_lb_rule" "main" {
#   resource_group_name            = data.azurerm_resource_group.mgmt.name
#   loadbalancer_id                = azurerm_lb.main.id
#   name                           = "${local.resource_prefix}-lb-rule"
#   protocol                       = "Tcp"
#   frontend_port                  = 80
#   backend_port                   = 80
#   frontend_ip_configuration_name = "${local.resource_prefix}-lb-frontend"
#   backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
#   probe_id                       = azurerm_lb_probe.main.id
# }


##################### APPLICATION GATEWAY CREATION ####################################

# data "azurerm_key_vault_secret" "ssl_cert_password" {
#   name         = local.ssl_cert_pass_key
#   key_vault_id = "${data.azurerm_key_vault.keyvault.id}"
# }

data "azurerm_subnet" "apgtwy_subnet" {
  name                 = local.apgtwy_subnet
  resource_group_name  = data.azurerm_resource_group.mgmt.name
  virtual_network_name = data.azurerm_virtual_network.mgmtnetwork.name
}

resource "azurerm_application_gateway" "main" {
  name                = "${local.resource_prefix}-apgtwy"
  resource_group_name = data.azurerm_resource_group.mgmt.name
  location            = data.azurerm_resource_group.mgmt.location

  sku {
    name     = local.sku_name
    tier     = local.sku_tier
    capacity = 1
  }
  # autoscale_configuration {
  #   min_capacity = local.min_capacity
  #   max_capacity = local.max_capacity
  # }

  gateway_ip_configuration {
    name      = "apgtwy-ipconfig"
    subnet_id = data.azurerm_subnet.apgtwy_subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 3000
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgtwy-pubip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 3000
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    #ssl_certificate_name           = "${local.resource_prefix}-sslcert"
  }
  # ssl_certificate {
  #   name                           = "${local.resource_prefix}-sslcert"
  #   data                           = filebase64(local.ssl_cert_file)
  #   password                       = "${data.azurerm_key_vault_secret.ssl_cert_password.value}"
  # }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
  tags = {
    environment = var.env
	  location    = var.region
	  cust_code   = local.cust_code
  }
}
