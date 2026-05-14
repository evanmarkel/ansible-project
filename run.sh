#!/usr/bin/env bash
set -e

echo "🚀 Starting Docker hosts..."
docker compose up -d host-a host-b

echo "⏳ Waiting for SSH ports to open..."
for port in 2222 2223; do
  until nc -z localhost "$port"; do
    sleep 1
  done
done

echo "🔍 Running SSH validator..."
./validate-ssh.sh

echo "🔐 SSH validated. Running Ansible provisioning..."
ansible-playbook -i ansible/inventory ansible/site.yml

echo "📊 Starting Prometheus and Grafana..."
docker compose up -d prometheus grafana

echo ""
echo "🎉 Environment is ready!"
echo "Prometheus: http://localhost:9090"
echo "Grafana:    http://localhost:3000"
