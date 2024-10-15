#!/bin/bash

# Переход в каталог Terraform
cd /root/fops-sysadm-diplom/terraform

# Применить изменения в Terraform
terraform apply -auto-approve

# Обновить инвентарь Ansible
python3 /root/fops-sysadm-diplom/ansible/update_inventory.py
