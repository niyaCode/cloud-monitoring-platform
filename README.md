# cloud-monitoring-platform
'cloud-monitoring-platform' is a highly available centralized monitoring product on Azure cloud which has advanced security, alerting and visualization features and is equipped with fully automated installation capabilities for various end-customers.

<h1>**Resource provisioning:**
The resource provisioning is done using Terraform.

The below is the list of Azure resources created:

Resource Group
VNets, Subnets
VMs ( for Prometheus and Central exporters)
VM Scale Set ( for Cortex, Cassandra and Grafana)
Azure internal Load balancer
Azure Application Gateway
Azure Frontdoor
Azure MySQL DB
