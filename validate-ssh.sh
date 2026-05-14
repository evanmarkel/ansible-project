#!/usr/bin/env bash
set -e

KEY="./ssh/id_rsa"
AUTH="./ssh/authorized_keys"

HOSTS=(
  "host-a:2222"
  "host-b:2223"
)

echo "🔍 Validating SSH setup..."

# 1. Check private key exists
if [[ ! -f "$KEY" ]]; then
  echo "❌ Private key not found at $KEY"
  exit 1
fi

# 2. Fix permissions if needed
if [[ $(stat -f "%Lp" "$KEY") != "600" ]]; then
  echo "⚠️ Fixing private key permissions..."
  chmod 600 "$KEY"
fi

# 3. Check authorized_keys exists
if [[ ! -f "$AUTH" ]]; then
  echo "❌ authorized_keys not found at $AUTH"
  exit 1
fi

# 4. Validate SSH connectivity to each host
for entry in "${HOSTS[@]}"; do
  HOST="${entry%%:*}"
  PORT="${entry##*:}"

  echo ""
  echo "➡️  Checking SSH for $HOST on port $PORT..."

  ssh -i "$KEY" \
      -o StrictHostKeyChecking=no \
      -o ConnectTimeout=3 \
      root@localhost -p "$PORT" \
      "echo 'SSH OK on $HOST'" \
    && echo "✅ SSH connection to $HOST succeeded" \
    || { echo "❌ SSH connection to $HOST failed"; exit 1; }
done

echo ""
echo "🎉 All SSH checks passed successfully!"
