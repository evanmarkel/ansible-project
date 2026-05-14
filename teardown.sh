#!/usr/bin/env bash
set -euo pipefail

echo "🧹 Tearing down observability stack..."

# Detect the docker compose project name (usually the folder name)
PROJECT_NAME=$(docker compose ls --format '{{.Name}}' | head -n 1)

if [ -z "$PROJECT_NAME" ]; then
  echo "⚠️  Could not detect project name automatically. Falling back to folder name."
  PROJECT_NAME=$(basename "$PWD")
fi

echo "📛 Using project name: $PROJECT_NAME"

# Stop and remove containers, networks, and default resources
docker compose down

echo "🗑 Removing persistent volumes..."
VOLUMES=(
  "${PROJECT_NAME}_host-a-data"
  "${PROJECT_NAME}_host-b-data"
  "${PROJECT_NAME}_grafana-data"
  "${PROJECT_NAME}_prometheus-data"
)

for VOL in "${VOLUMES[@]}"; do
  if docker volume inspect "$VOL" >/dev/null 2>&1; then
    echo "  - Removing volume: $VOL"
    docker volume rm "$VOL" >/dev/null
  else
    echo "  - Volume not found (skipping): $VOL"
  fi
done

echo "✨ Teardown complete!"
