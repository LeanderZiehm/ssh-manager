#!/usr/bin/env bash

set -euo pipefail

# ---- config ----
SERVER_NAME="erl"
DESCRIPTION="request-access-${SERVER_NAME}"
KEY_DIR="$HOME/.ssh"

# automatically generate name from hostname
HOSTNAME=$(hostname)
USERNAME=$(whoami)
IDENTITY="$(whoami) $(hostname)"
# KEY_NAME="${HOSTNAME}"
KEY_NAME="request-ssh-${SERVER_NAME}-leanderziehm-com"
KEY_PATH="$KEY_DIR/id_${KEY_NAME}"
API_URL="https://request-ssh.${SERVER_NAME}.leanderziehm.com/register"

# ---- ensure ssh dir exists ----
mkdir -p "$KEY_DIR"
chmod 700 "$KEY_DIR"

# ---- generate key ----
if [[ -f "$KEY_PATH" ]]; then
  echo "Key already exists: $KEY_PATH"
  exit 1
fi

ssh-keygen \
  -t ed25519 \
  -f "$KEY_PATH" \
  -N "" \
  -C "$IDENTITY"

# ---- read public key ----
PUBLIC_KEY=$(cat "${KEY_PATH}.pub")

# ---- send to API ----
curl -X POST "$API_URL" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$(jq -n \
    --arg name "-" \
    --arg description "$DESCRIPTION" \
    --arg public_key "$PUBLIC_KEY" \
    '{
      name: $name,
      description: $description,
      public_key: $public_key
    }'
  )"

echo "1. Add your key on the server to access."
echo "2. run: ssh -i ~/.ssh/id_ssh-request-leanderziehm-com -o IdentitiesOnly=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o ExitOnForwardFailure=yes -N -T -R 7700:localhost:9000 -R 9922:localhost:9922 erl@ssh.erl.leanderziehm.com"
echo "3. ssh -i $KEY_PATH  u@ip"