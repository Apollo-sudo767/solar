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

# 2. Key Selection
echo "🔑 Host Key Setup:"
echo "1) Generate a NEW SSH host key (Recommended for fresh install)"
echo "2) Use EXISTING host key (Requires you to have the private key file ready)"
read -p "Select [1-2]: " KEY_CHOICE

if [[ "$KEY_CHOICE" == "1" ]]; then
    echo "🆕 Generating new SSH host key..."
    ssh-keygen -t ed25519 -f "$TEMP_DIR/ssh_host_ed25519_key" -N "" -C "root@$HOST"
    
    echo "📝 Converting to age format and updating solar-secrets..."
    nix run nixpkgs#ssh-to-age -- < "$TEMP_DIR/ssh_host_ed25519_key.pub" > "$SECRETS_DIR/hosts/$HOST.pub"
    
    echo "🔐 Rekeying secrets..."
    echo "I will now try to run the rekeying process. If it fails due to YubiKey/PIN issues,"
    echo "don't worry—you can run 's-rekey' manually afterwards and then restart this script."
    
    if ! AGENIX_REKEY_PRIMARY_FLAKE_ROOT="$FLAKE_DIR" nix run --override-input solar-secrets "path:$SECRETS_DIR" --no-write-lock-file "$FLAKE_DIR#agenix-rekey-rekey" -- -a; then
        echo "❌ Rekeying failed."
        echo "Please run 's-rekey' manually in another terminal to ensure your YubiKey is working,"
        echo "then run this script again and select 'Use EXISTING host key' (since the key was already generated in $TEMP_DIR)."
        exit 1
    fi

    echo "🐙 Staging newly generated secrets in git..."
    git -C "$SECRETS_DIR" add -A
else
    read -p "Enter path to the EXISTING private SSH host key: " PRIV_KEY_PATH
    if [[ ! -f "$PRIV_KEY_PATH" ]]; then
        echo "❌ Private key file not found at $PRIV_KEY_PATH"
        exit 1
    fi
    cp "$PRIV_KEY_PATH" "$TEMP_DIR/ssh_host_ed25519_key"
    ssh-keygen -y -f "$TEMP_DIR/ssh_host_ed25519_key" > "$TEMP_DIR/ssh_host_ed25519_key.pub"
    
    # Ensure solar-secrets is in sync with this existing key
    nix run nixpkgs#ssh-to-age -- < "$TEMP_DIR/ssh_host_ed25519_key.pub" > "$SECRETS_DIR/hosts/$HOST.pub"
    echo "🔐 Ensuring secrets are rekeyed for this host (using path override)..."
    AGENIX_REKEY_PRIMARY_FLAKE_ROOT="$FLAKE_DIR" nix run --override-input solar-secrets "path:$SECRETS_DIR" --no-write-lock-file "$FLAKE_DIR#agenix-rekey-rekey" -- -a

    echo "🐙 Staging secrets updates in git..."
    git -C "$SECRETS_DIR" add -A
fi

# 3. Prepare nixos-anywhere extra-files
echo "📦 Preparing extra-files payload..."
PAYLOAD_DIR="$TEMP_DIR/payload"
mkdir -p "$PAYLOAD_DIR/etc/ssh"
cp "$TEMP_DIR/ssh_host_ed25519_key" "$PAYLOAD_DIR/etc/ssh/"
cp "$TEMP_DIR/ssh_host_ed25519_key.pub" "$PAYLOAD_DIR/etc/ssh/"
chmod 600 "$PAYLOAD_DIR/etc/ssh/ssh_host_ed25519_key"
chmod 644 "$PAYLOAD_DIR/etc/ssh/ssh_host_ed25519_key.pub"

# 4. Execute nixos-anywhere
echo "📡 Executing nixos-anywhere..."
echo "If you set a password on the live USB, nixos-anywhere will prompt for it now."
nix run github:nix-community/nixos-anywhere -- \
    --flake "$FLAKE_DIR#$HOST" \
    --extra-files "$PAYLOAD_DIR" \
    "root@$TARGET_IP"

echo "✅ Reinstallation of $HOST initiated successfully!"
