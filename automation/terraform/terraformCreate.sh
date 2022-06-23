#!/bin/bash

# Creating resource group
cd rg
terraform plan -out rg.tfplan
terraform apply "rg.tfplan"

# Creating virtual networks
cd ../vnet
terraform plan -out vnet.tfplan
terraform apply "vnet.tfplan"

# Creating keyvault
cd ../kv
terraform plan -out kv.tfplan
terraform apply "kv.tfplan"

# Creating ansible master
cd ../ans
terraform plan -out ans.tfplan
terraform apply "ans.tfplan"

# Creating the main resources for monitoring platform
cd ../main
terraform plan -out main.tfplan
terraform apply "main.tfplan"

#Creating inventory config file for ansible
# cd ../file
# terraform get
# terraform init -input=false
# terraform plan  -input=false
# terraform apply -auto-approve
# . export-variables.sh
# echo $ENV
# cd ../../core/script
# bash get_ip_infor.sh

