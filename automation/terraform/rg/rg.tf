
######################## Create Resource Group ##############################
resource "azurerm_resource_group" "mgmt" {
  name     = "${local.resource_prefix}-rg"
  location = var.resource_group_location
}



