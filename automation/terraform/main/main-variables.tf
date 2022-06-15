variable "project" {
  description = "Project Code or Name"
  type        = string
  default = "csc-mon"
}

variable "env" {
  description = "Environment where the resources will be provisioned"
  type        = string
  default     = "poc"
}

variable "region" {
  description = "Management Console Region"
  type        = string
  default     = "in"
}

variable "tfspn_client_id" {
  default = "<<Insert tfspn_client_id>>"
  description   = "Terraform spn client id"
}

variable "tfspn_client_secret" {
  default = "<<Insert tfspn_client_secret>>"
  description   = "Terraform spn client secret"
}

variable "azure_tenant_id" {
  default = "<<Insert azure_tenant_id>>"
  description   = "Azure tenant Id"
}

variable "resource_group_name_prefix" {
  default       = "rg"
  description   = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "resource_group_location" {
  default = "southindia"
  description   = "Location of the resource group."
}

locals {

  subscription_id                 = "<<Insert Azure subscription_id>>"
  resource_prefix                 = "${var.project}-${var.env}-${var.region}"
  rg                              = "${local.resource_prefix}-rg"
  kv                              = "${local.resource_prefix}-kv"
  mgmtVnet                        = "${local.resource_prefix}-mgmtVnet"
  promSubnet                      = "${local.resource_prefix}-prom-subnet"
  lb_subnet                       = "${local.resource_prefix}-prom-subnet"
  
}

variable vm-app {
  description = "Application List for VM"
  type        = map
  default     = {
    prometheus-1 = {
    application = "prometheus",
	  subnet = "csc-mon-poc-in-prom-subnet",
	  managed_disk_type  = "Premium_LRS",
	  disk_size_gb = 64,
	  zones = ["1"],
	  sku = "18.04-LTS",
	  vm_size = "Standard_D8s_v3",
      userid = "custsrvadmin",
	  password_key = "vm-prometheus-custsrvadmin"
    }
	  # prometheus-2 = {
    # application = "prometheus",
	  # subnet = "csc-mon-poc-in-prom-subnet",
	  # managed_disk_type  = "Premium_LRS",
	  # disk_size_gb = 64,
	  # zones = ["2"],
	  # sku = "18.04-LTS",
	  # vm_size = "Standard_D8s_v3",
    # userid = "custsrvadmin",
	  # password_key = "vm-prometheus-custsrvadmin"
    # },
	  # prometheus-3 = {
    # application = "prometheus",
	  # subnet = "csc-mon-poc-in-prom-subnet",
	  # managed_disk_type  = "Premium_LRS",
	  # disk_size_gb = 64,
	  # zones = ["3"],
	  # sku = "18.04-LTS",
	  # vm_size = "Standard_D8s_v3",
    # userid = "custsrvadmin",
	  # password_key = "vm-prometheus-custsrvadmin"
    # },
    # exporter-1 = {
    # application = "exporter",
	  # subnet = "csc-mon-poc-in-prom-subnet",
	  # managed_disk_type  = "Premium_LRS",
	  # disk_size_gb = 64,
	  # zones = ["1"],
	  # sku = "18.04-LTS",
	  # vm_size = "Standard_D8s_v3",
    #   userid = "custsrvadmin",
	  # password_key = "vm-exporter-custsrvadmin"
    # }
  }
}

variable vmss-app {
  description = "Application List for VM Scale Set"
  type        = map
  default     = {
    grafana = {
      application = "grafana",
	    subnet = "csc-mon-poc-in-prom-subnet",
	    #managed_disk_type  = "Premium_LRS",
      managed_disk_type  = "Standard_LRS",
	    disk_size_gb = 64,
	    zones = ["1","2","3"],
	    instance_count = 1,
	    sku = "18.04-LTS",
      #vm_size = "Standard_D8s_v3",
      vm_size = "Standard_DS1",
	    userid = "custsrvadmin",
	    password_key = "vm-grafana-custsrvadmin"
    }
	# cortex = {
  #     application = "cortex",
	#   subnet = "moni-prd-cortex-subnet",
	#   managed_disk_type  = "Premium_LRS",
	#   disk_size_gb = 512,
	#   zones = ["1","2","3"],
	#   instance_count = 2,
	#   sku = "18.04-LTS",
  #     vm_size = "Standard_D8s_v3",
	#   userid = "custsrvadmin",
	#   password_key = "vm-cortex-custsrvadmin"
  #   },
	# cassandra = {
  #     application = "cassandra",
	#   subnet = "moni-prd-cortex-subnet",
	#   managed_disk_type  = "Premium_LRS",
	#   disk_size_gb = 1024,
	#   zones = ["1","2","3"],
	#   instance_count = 2,
	#   sku = "18.04-LTS",
  #     vm_size = "Standard_D8s_v3",
	#   userid = "custsrvadmin",
	#   password_key = "vm-cassandra-custsrvadmin"
  #   }
  }
}