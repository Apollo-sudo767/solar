#!/usr/bin/env bash

# Exit on error
set -e

# Configuration
HOST="mercury"
FLAKE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_DIR="$(cd "$FLAKE_DIR/../solar-secrets" && pwd)"
TEMP_DIR=$(mktemp -d)

# Ensure cleanup on exit
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "🚀 Preparing reinstallation for $HOST..."

# 1. Gather target information
read -p "Enter the target IP address for $HOST: " TARGET_IP
if [[ -z "$TARGET_IP" ]]; then
    echo "❌ IP address is required."
    exit 1
fi

# 2. Generate new SSH host key
echo "🔑 Generating new SSH host key..."
ssh-keygen -t ed25519 -f "$TEMP_DIR/ssh_host_ed25519_key" -N "" -C "root@$HOST"

# 3. Update solar-secrets with the new public key
echo "📝 Updating public key in solar-secrets..."
cat "$TEMP_DIR/ssh_host_ed25519_key.pub" > "$SECRETS_DIR/hosts/$HOST.pub"

# 4. Rekey secrets
echo "🔐 Rekeying secrets (Touch your YubiKey if prompted)..."
# We need to ensure nix recognizes the change in solar-secrets
# Using --override-input to point to the local secrets repo
AGENIX_REKEY_PRIMARY_FLAKE_ROOT="$FLAKE_DIR" nix run --override-input solar-secrets "path:$SECRETS_DIR" --no-write-lock-file "$FLAKE_DIR#agenix-rekey-rekey" -- -a

# 5. Prepare nixos-anywhere extra-files
echo "📦 Preparing extra-files payload..."
PAYLOAD_DIR="$TEMP_DIR/payload"
mkdir -p "$PAYLOAD_DIR/etc/ssh"
cp "$TEMP_DIR/ssh_host_ed25519_key" "$PAYLOAD_DIR/etc/ssh/"
cp "$TEMP_DIR/ssh_host_ed25519_key.pub" "$PAYLOAD_DIR/etc/ssh/"
chmod 600 "$PAYLOAD_DIR/etc/ssh/ssh_host_ed25519_key"
chmod 644 "$PAYLOAD_DIR/etc/ssh/ssh_host_ed25519_key.pub"

# 6. Execute nixos-anywhere
echo "📡 Executing nixos-anywhere..."
nix run github:nix-community/nixos-anywhere -- \
    --flake "$FLAKE_DIR#$HOST" \
    --extra-files "$PAYLOAD_DIR" \
    "root@$TARGET_IP"

echo "✅ Reinstallation of $HOST initiated successfully!"
