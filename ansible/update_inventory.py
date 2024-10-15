import json
import subprocess
import os

# Убедитесь, что скрипт запускается из каталога Ansible
os.chdir(os.path.dirname(os.path.abspath(__file__)))

# Выполните команду terraform output и получите выходные данные
output = subprocess.check_output(["terraform", "output", "-json", "-state=../terraform/terraform.tfstate"])
terraform_outputs = json.loads(output)

# Получение IP-адресов из выходных данных
bastion_ip = terraform_outputs['bastion_ip']['value']['wan_ip']
webvm_ips = terraform_outputs['webvm_ip']['value']
prometheus_ip = terraform_outputs['prometrheus_ip']['value']['lan']
elasticsearch_ip = terraform_outputs['elasticsearch_ip']['value']['lan']
grafana_ip = terraform_outputs['grafana_ip']['value']['lan_ip']
kibana_ip = terraform_outputs['kibana_ip']['value']['lan_ip']

# Генерация инвентаря Ansible
inventory = f"""
all:
  children:
    bastion_h:
      hosts:
        bastion:
          ansible_host: {bastion_ip}
          ansible_user: v3ll
          ansible_ssh_private_key_file: /root/fops-sysadm-diplom/ansible/file/keyssh
    web_hosts:
      hosts:
        webvm1:
          ansible_host: {webvm_ips[0]}
          ansible_user: v3ll
          ansible_ssh_private_key_file: /root/fops-sysadm-diplom/ansible/file/keyssh
          ansible_ssh_common_args: >-
            -o ProxyCommand="ssh -i /root/fops-sysadm-diplom/ansible/file/keyssh -W %h:%p v3ll@{bastion_ip}" -o StrictHostKeyChecking=no
        webvm2:
          ansible_host: {webvm_ips[1]}
          ansible_user: v3ll
          ansible_ssh_private_key_file: /root/fops-sysadm-diplom/ansible/file/keyssh
          ansible_ssh_common_args: >-
            -o ProxyCommand="ssh -i /root/fops-sysadm-diplom/ansible/file/keyssh -W %h:%p v3ll@{bastion_ip}" -o StrictHostKeyChecking=no
    prometheus:
      hosts:
        vm-prometheus:
          ansible_host: {prometheus_ip}
          ansible_user: v3ll
          ansible_ssh_private_key_file: /root/fops-sysadm-diplom/ansible/file/keyssh
          ansible_ssh_common_args: >-
            -o ProxyCommand="ssh -i /root/fops-sysadm-diplom/ansible/file/keyssh -W %h:%p v3ll@{bastion_ip}" -o StrictHostKeyChecking=no
    grafana:
      hosts:
        vm-grafana:
          ansible_host: {grafana_ip}
          ansible_user: v3ll
          ansible_ssh_private_key_file: /root/fops-sysadm-diplom/ansible/file/keyssh
          ansible_ssh_common_args: >-
            -o ProxyCommand="ssh -i /root/fops-sysadm-diplom/ansible/file/keyssh -W %h:%p v3ll@{bastion_ip}" -o StrictHostKeyChecking=no
    elasticsearch:
      hosts:
        vm-ES:
          ansible_host: {elasticsearch_ip}
          ansible_user: v3ll
          ansible_ssh_private_key_file: /root/fops-sysadm-diplom/ansible/file/keyssh
          ansible_ssh_common_args: >-
            -o ProxyCommand="ssh -i /root/fops-sysadm-diplom/ansible/file/keyssh -W %h:%p v3ll@{bastion_ip}" -o StrictHostKeyChecking=no
    kibana:
      hosts:
        vm-kibana:
          ansible_host: {kibana_ip}
          ansible_user: v3ll
          ansible_ssh_private_key_file: /root/fops-sysadm-diplom/ansible/file/keyssh
          ansible_ssh_common_args: >-
            -o ProxyCommand="ssh -i /root/fops-sysadm-diplom/ansible/file/keyssh -W %h:%p v3ll@{bastion_ip}" -o StrictHostKeyChecking=no
"""

# Запись инвентаря в файл
with open('inventory/inventory.yml', 'w') as f:
    f.write(inventory)

print("Ansible inventory has been updated successfully.")
