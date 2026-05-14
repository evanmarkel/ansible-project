#!/usr/bin/env bash
set -e

echo "🚀 Starting SSHD-mode containers..."
docker compose up -d host-a host-b

echo "⏳ Waiting for SSHD to become ready..."
sleep 3

echo "🔧 Running Ansible provisioning..."
ansible-playbook -i ./ansible/inventory/hosts.yml ./ansible/site.yml

echo "📦 Committing provisioned containers into Alloy images..."
docker commit host-a host-a-alloy
docker commit host-b host-b-alloy

echo "🧹 Removing SSHD-mode containers..."
docker rm -f host-a host-b 2>/dev/null || true

echo "🔄 Starting Alloy-mode containers..."
docker run -d --name host-a --network observability \
  host-a-alloy /usr/local/bin/alloy --config.file=/etc/alloy/config.yaml

docker run -d --name host-b --network observability \
  host-b-alloy /usr/local/bin/alloy --config.file=/etc/alloy/config.yaml

echo "🚀 Starting Prometheus and Grafana..."
docker compose up -d prometheus grafana

echo "✅ All Services are up!"
echo "📊 Prometheus: http://localhost:9090"
echo "📈 Grafana:    http://localhost:3000"
