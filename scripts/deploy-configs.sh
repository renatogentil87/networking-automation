#!/bin/bash
set -e

cd /home/ubuntu/network-lab

echo "Deploying BGP configurations..."
ansible-playbook playbooks/deploy-bgp.yml -i inventory/lab.ini ---vvv

echo "✓ Deployment completed"
