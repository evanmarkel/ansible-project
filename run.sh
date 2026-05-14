#!/usr/bin/env bash
set -e

echo "🚀 Starting SSHD-mode containers..."
docker compose up -d host-a host-b

echo "⏳ Waiting for SSHD to become ready..."
sleep 3

echo "🔧 Running Ansible provisioning..."
ansible-playbook -i ./ansible/inventory/hosts.yml ./ansible/site.yml

echo "📦 Building Alloy images from clean Dockerfiles..."
docker build -t host-a-alloy -f docker/alloy/Dockerfile /tmp/host-a
docker build -t host-b-alloy -f docker/alloy/Dockerfile /tmp/host-b

echo "🧹 Removing SSHD-mode containers..."
docker rm -f host-a host-b 2>/dev/null || true

echo "🔄 Starting Alloy-mode containers..."
docker run -d --name host-a --network observability host-a-alloy
docker run -d --name host-b --network observability host-b-alloy

echo "🚀 Starting Prometheus and Grafana..."
docker compose up -d prometheus grafana

echo "✅ All Services are up!"
echo "📊 Prometheus: http://localhost:9090"
echo "📈 Grafana:    http://localhost:3000"

