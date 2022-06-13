
######################## LOAD COMMON COMPONENTS ############################

# Resource Group
data "azurerm_resource_group" "mgmt" {
    name      = local.rg
}

######################## Create virtual network ############################## 

resource "azurerm_virtual_network" "mgmtnetwork" {
  name                = "${local.resource_prefix}-mgmtVnet"
  address_space       = ["10.1.0.0/28"]
  location            = data.azurerm_resource_group.mgmt.location
  resource_group_name = data.azurerm_resource_group.mgmt.name
}

resource "azurerm_virtual_network" "ansiblenetwork" {
  name                = "${local.resource_prefix}-ansibleVnet"
  address_space       = ["10.2.0.0/28"]
  location            = data.azurerm_resource_group.mgmt.location
  resource_group_name = data.azurerm_resource_group.mgmt.name
}

######################## Create subnet ############################## 

resource "azurerm_subnet" "promsubnet" {
  name                 = "${local.resource_prefix}-prom-subnet"
  resource_group_name  = data.azurerm_resource_group.mgmt.name
  virtual_network_name = azurerm_virtual_network.mgmtnetwork.name
  address_prefixes     = ["10.1.0.0/29"]
}

resource "azurerm_subnet" "ansiblesubnet" {
  name                 = "${local.resource_prefix}-ansible-subnet"
  resource_group_name  = data.azurerm_resource_group.mgmt.name
  virtual_network_name = azurerm_virtual_network.ansiblenetwork.name
  address_prefixes     = ["10.2.0.0/29"]
}


################## Create Vnet peering  ########################

resource "azurerm_virtual_network_peering" "mgmtToAnsible" {
  name                      = "peerMgmtToAnsible"
  resource_group_name       = data.azurerm_resource_group.mgmt.name
  virtual_network_name      = azurerm_virtual_network.mgmtnetwork.name
  remote_virtual_network_id = azurerm_virtual_network.ansiblenetwork.id
}

resource "azurerm_virtual_network_peering" "ansibleToMgmt" {
  name                      = "peerAnsibleToMgmt"
  resource_group_name       = data.azurerm_resource_group.mgmt.name
  virtual_network_name      = azurerm_virtual_network.ansiblenetwork.name
  remote_virtual_network_id = azurerm_virtual_network.mgmtnetwork.id
}


