#!/bin/bash
cd /tmp
rm -rf cloud-monitoring-platform
git clone https://github.com/niyaCode/cloud-monitoring-platform.git
cd /home/ansibleadmin/
rm -rf ansible
mkdir ansible
cd ansible
cp /tmp/export-variables.sh /tmp/inventory.cfg .

cp /tmp/cloud-monitoring-platform/automation/ansible/cmp.yml .
cp -r /tmp/cloud-monitoring-platform/automation/ansible/roles .
. export-variables.sh
echo $ENV
ansible-playbook -i inventory.cfg cmp.yml

