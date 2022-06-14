data "azurerm_resource_group" "mgmt" {
  name      = local.rg
}

######################## Create Key Vault ##############################

resource "azurerm_key_vault" "main" {
  name                        = "${local.resource_prefix}-kv"
  location                    = data.azurerm_resource_group.mgmt.location
  resource_group_name         = data.azurerm_resource_group.mgmt.name
  #enabled_for_disk_encryption = true
  tenant_id                   = var.azure_tenant_id
  #soft_delete_enabled         = false
  #soft_delete_retention_days  = 90
  #purge_protection_enabled    = true

  sku_name = "standard"

# access policy for terraform contributor spn
  access_policy {
    tenant_id = var.azure_tenant_id
    object_id = var.tfspn_obj_id

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get", "list", "set", "delete", "backup", "recover", "restore", "purge"
    ]

    storage_permissions = [
      "get",
    ]
  }

  #access policy for keyvault reader spn / any user principal who needs access to kv
  access_policy {
    tenant_id = var.azure_tenant_id
    object_id = var.usr_obj_id

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get", "list", "set", "delete", "backup", "recover", "restore", "purge"
    ]

    storage_permissions = [
      "get",
    ]
  }

  tags = {
    environment   = var.env
	  location      = var.region
	  #customercode  = local.cust_code
	  application   = "keyvault"
  }  
}


######################## Password Generation ############################

resource "random_password" "password" {
  for_each = var.passwords
  length = 16
  special = true
  override_special = "_%@"
}

resource "azurerm_key_vault_secret" "secret" {
  for_each = var.passwords
  name         = each.key
  value        = random_password.password[each.key].result
  key_vault_id = "${azurerm_key_vault.main.id}"

  tags = {
    environment   = var.env
	  location      = var.region
	  #customercode  = local.cust_code
	  application   = "secret"
  }
}