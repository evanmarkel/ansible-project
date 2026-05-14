#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Preflight checks..."

# --- 1. Ensure inventory loads ---
echo "➡ Validating Ansible inventory..."
if ! ansible-inventory -i ansible/inventory/hosts.yml --list >/dev/null 2>&1; then
    echo "❌ ERROR: Inventory file is invalid or cannot be parsed."
    exit 1
fi

# --- 2. Ensure monitored group exists ---
if ! ansible-inventory -i ansible/inventory/hosts.yml --list | jq -e '.monitored.hosts' >/dev/null 2>&1; then
    echo "❌ ERROR: No 'monitored' group found in inventory."
    exit 1
fi

# --- 3. Ensure Ansible is NOT using sudo/become ---
echo "➡ Checking privilege escalation settings..."
if ansible-config dump | grep -q "BECOME=True"; then
    echo "❌ ERROR: Ansible is configured to use sudo/become. Disable it."
    exit 1
fi

# --- 4. Ensure Docker is running ---
echo "➡ Checking Docker daemon..."
if ! docker info >/dev/null 2>&1; then
    echo "❌ ERROR: Docker is not running."
    exit 1
fi

# --- 5. Ensure observability network exists ---
echo "➡ Ensuring Docker network 'observability' exists..."
docker network create observability >/dev/null 2>&1 || true

echo "✔ Preflight checks passed!"
echo ""

# --- 6. Run Ansible ---
echo "🔧 Running Ansible..."
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml

echo ""
echo "📦 Building Alloy images..."

# --- 7. Build images for all monitored hosts ---
for host in $(ansible-inventory -i ansible/inventory/hosts.yml --list | jq -r '.monitored.hosts | keys[]'); do
    output_dir=$(ansible-inventory -i ansible/inventory/hosts.yml --host "$host" | jq -r '.output_dir')

    if [[ ! -d "$output_dir" ]]; then
        echo "❌ ERROR: Expected directory '$output_dir' does not exist. Ansible may have failed."
        exit 1
    fi

    echo "➡ Building image for $host from $output_dir"
    docker build -t "${host}-alloy" -f docker/alloy/Dockerfile "$output_dir"
done

echo ""
echo "🚀 Starting Alloy containers..."

# --- 8. Start containers for all monitored hosts ---
for host in $(ansible-inventory -i ansible/inventory/hosts.yml --list | jq -r '.monitored.hosts | keys[]'); do
    echo "➡ Starting container for $host"
    docker rm -f "$host" >/dev/null 2>&1 || true
    docker run -d --name "$host" --network observability "${host}-alloy"
done

echo ""
echo "📊 Starting Prometheus + Grafana..."
docker compose up -d prometheus grafana

echo ""
echo "🎉 All services running!"
echo "Prometheus → http://localhost:9090"
echo "Grafana    → http://localhost:3000"
