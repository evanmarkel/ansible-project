#!/bin/bash
set -e

echo "🔻 Stopping and removing containers..."
docker compose down -v

echo "🧼 Removing dangling Docker resources..."
docker system prune -f

echo "🗑  Cleaning known_hosts entries for host-a and host-b..."
ssh-keygen -R "[127.0.0.1]:2222" >/dev/null 2>&1 || true
ssh-keygen -R "[127.0.0.1]:2223" >/dev/null 2>&1 || true
ssh-keygen -R "127.0.0.1" >/dev/null 2>&1 || true
ssh-keygen -R "localhost" >/dev/null 2>&1 || true

echo "✨ Teardown complete."
