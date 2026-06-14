#!/usr/bin/env bash

# Exit on error
set -e

# Configuration
FLAKE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_DIR="${SECRETS_DIR:-$(cd "$FLAKE_DIR/../solar-secrets" 2>/dev/null && pwd || echo "$HOME/.solar-secrets")}"
TEMP_DIR=$(mktemp -d)

# Ensure cleanup on exit
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "☀️ Solar Reinstallation Script"

# 0. Host Selection
HOST=$1
if [[ -z "$HOST" ]]; then
    echo "🔍 Available hosts:"
    ls "$FLAKE_DIR/modules/hosts" | grep -v "default.nix\|shared"
    read -p "Select a host to reinstall: " HOST
fi

if [[ ! -d "$FLAKE_DIR/modules/hosts/$HOST" ]]; then
    echo "❌ Host '$HOST' not found in modules/hosts/"
    exit 1
fi

echo "🚀 Preparing reinstallation for $HOST..."

# 1. Gather target information
read -p "Enter the target IP address for $HOST: " TARGET_IP
if [[ -z "$TARGET_IP" ]]; then
    echo "❌ IP address is required."
    exit 1
fi

# 2. SSH Key Selection
echo "🔑 Host Key Setup:"
echo "1) Generate a NEW SSH host key (Recommended for fresh install)"
echo "2) Use EXISTING host key (Requires you to have the private key file ready)"
read -p "Select [1-2]: " KEY_CHOICE

if [[ "$KEY_CHOICE" == "1" ]]; then
    echo "🆕 Generating new SSH host key..."
    ssh-keygen -t ed25519 -f "$TEMP_DIR/ssh_host_ed25519_key" -N "" -C "root@$HOST"
    
    echo "📝 Updating solar-secrets with raw SSH public key..."
    cp "$TEMP_DIR/ssh_host_ed25519_key.pub" "$SECRETS_DIR/hosts/$HOST.pub"
    
    echo "🔐 Rekeying secrets..."
    echo "I will now try to run the rekeying process. If it fails due to YubiKey/PIN issues,"
    echo "don't worry—you can run 'nix run .#agenix-rekey-rekey' manually afterwards and then restart this script."
    
    if ! AGENIX_REKEY_PRIMARY_FLAKE_ROOT="$FLAKE_DIR" nix run --override-input solar-secrets "path:$SECRETS_DIR" --no-write-lock-file "$FLAKE_DIR#agenix-rekey-rekey" ; then
        echo "❌ Rekeying failed."
        echo "Please ensure your YubiKey is working and run the rekeying manually,"
        echo "then run this script again and select 'Use EXISTING host key'."
        exit 1
    fi

    echo "🐙 Staging updates in both repositories..."
    git -C "$SECRETS_DIR" add -A
    git -C "$FLAKE_DIR" add "$FLAKE_DIR/rekeyed/$HOST"
else
    read -p "Enter path to the EXISTING private SSH host key: " PRIV_KEY_PATH
    if [[ ! -f "$PRIV_KEY_PATH" ]]; then
        echo "❌ Private key file not found at $PRIV_KEY_PATH"
        exit 1
    fi
    cp "$PRIV_KEY_PATH" "$TEMP_DIR/ssh_host_ed25519_key"
    ssh-keygen -y -f "$TEMP_DIR/ssh_host_ed25519_key" > "$TEMP_DIR/ssh_host_ed25519_key.pub"
    
    # Ensure solar-secrets is in sync with this existing key
    cp "$TEMP_DIR/ssh_host_ed25519_key.pub" "$SECRETS_DIR/hosts/$HOST.pub"
    echo "🔐 Ensuring secrets are rekeyed for this host..."
    AGENIX_REKEY_PRIMARY_FLAKE_ROOT="$FLAKE_DIR" nix run --override-input solar-secrets "path:$SECRETS_DIR" --no-write-lock-file "$FLAKE_DIR#agenix-rekey-rekey"

    echo "🐙 Staging updates in both repositories..."
    git -C "$SECRETS_DIR" add -A
    git -C "$FLAKE_DIR" add "$FLAKE_DIR/rekeyed/$HOST"
fi

# 3. Prepare nixos-anywhere extra-files
echo "📦 Preparing extra-files payload..."
PAYLOAD_DIR="$TEMP_DIR/payload"

mkpath() {
    mkdir -p "$1"
    chmod "$2" "$1"
}

# Base directories
mkpath "$PAYLOAD_DIR" 755
mkpath "$PAYLOAD_DIR/etc" 755
mkpath "$PAYLOAD_DIR/etc/ssh" 755

# Standard location
cp "$TEMP_DIR/ssh_host_ed25519_key" "$PAYLOAD_DIR/etc/ssh/"
cp "$TEMP_DIR/ssh_host_ed25519_key.pub" "$PAYLOAD_DIR/etc/ssh/"
chmod 600 "$PAYLOAD_DIR/etc/ssh/ssh_host_ed25519_key"
chmod 644 "$PAYLOAD_DIR/etc/ssh/ssh_host_ed25519_key.pub"

# Persistence location (Mirror keys so they survive reboot on tmpfs-root systems)
echo "🔗 Mirroring keys to /persist/etc/ssh for persistence compatibility..."
mkpath "$PAYLOAD_DIR/persist" 755
mkpath "$PAYLOAD_DIR/persist/etc" 755
mkpath "$PAYLOAD_DIR/persist/etc/ssh" 755
cp "$TEMP_DIR/ssh_host_ed25519_key" "$PAYLOAD_DIR/persist/etc/ssh/"
cp "$TEMP_DIR/ssh_host_ed25519_key.pub" "$PAYLOAD_DIR/persist/etc/ssh/"
chmod 600 "$PAYLOAD_DIR/persist/etc/ssh/ssh_host_ed25519_key"
chmod 644 "$PAYLOAD_DIR/persist/etc/ssh/ssh_host_ed25519_key.pub"

# 4. Build and Execute
echo "🏗️ Building system and disko script locally with secrets override..."
DISKO_PATH=$(nix build ".#nixosConfigurations.$HOST.config.system.build.diskoScript" --override-input solar-secrets "path:$SECRETS_DIR" --no-link --print-out-paths --no-write-lock-file)
SYSTEM_PATH=$(nix build ".#nixosConfigurations.$HOST.config.system.build.toplevel" --override-input solar-secrets "path:$SECRETS_DIR" --no-link --print-out-paths --no-write-lock-file)

echo "📡 Executing nixos-anywhere..."
echo "If you set a password on the live USB, nixos-anywhere will prompt for it now."
nix run github:nix-community/nixos-anywhere -- \
    --store-paths "$DISKO_PATH" "$SYSTEM_PATH" \
    --extra-files "$PAYLOAD_DIR" \
    "root@$TARGET_IP"

echo ""
echo "✅ Reinstallation of $HOST initiated!"
echo "----------------------------------------------------------------------"
echo "🛠️  MANUAL POST-INSTALL STEPS"
echo "----------------------------------------------------------------------"
echo "1. Wait for the machine to reboot and enter your LUKS passphrase."
echo "2. Log in (via SSH or physically)."
echo "3. If using Secure Boot, run the following commands as root:"
echo ""
echo "   # Create keys if they don't exist"
echo "   sbctl create-keys"
echo ""
echo "   # Enroll keys (ensure machine is in UEFI Setup Mode)"
echo "   sbctl enroll-keys --microsoft"
echo ""
echo "   # Sign boot files and kernels"
echo "   find /boot -type f -name \"*.efi\" -exec sbctl sign -s {} +"
echo "   find /boot -type f \( -name \"vmlinuz*\" -o -name \"bzImage*\" \) -exec sbctl sign -s {} +"
echo ""
echo "   # If using Limine, disable internal hash verification to avoid panics"
echo "   sed -i \"s/hash_mismatch_panic: yes/hash_mismatch_panic: no/\" /boot/limine/limine.conf"
echo "   sed -i \"s/#[a-f0-9]\{64\}//g\" /boot/limine/limine.conf"
echo ""
echo "   # Finalize"
echo "   sync"
echo "   reboot"
echo "----------------------------------------------------------------------"
