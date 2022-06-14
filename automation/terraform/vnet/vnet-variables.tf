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
  
}