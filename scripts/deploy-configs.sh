#!/bin/bash
set -e

cd /home/ubuntu/network-lab

echo "Deploying BGP configurations..."
ansible-playbook playbooks/deploy-bgp.yml -i inventory/lab.ini
ansible-playbook playbooks/deploy-ospf.yml -i inventory/lab.ini

echo "✓ Deployment completed"
