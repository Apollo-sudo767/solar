#!/usr/bin/env bash

# Exit on error
set -e

# Configuration
FLAKE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_DIR=$(mktemp -d)

# Ensure cleanup on exit
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "☀️ Solar Installation Script"
echo "==================================="
echo "This script will guide you through the process of installing"
echo "NixOS onto a target machine using nixos-anywhere."
echo ""

# 1. Host Selection
echo "🔍 Available hosts:"
ls "$FLAKE_DIR/modules/hosts" | grep -v "default.nix\|shared"
echo ""

HOST=""
while [[ -z "$HOST" ]]; do
    read -p "Select a host to install: " HOST
    if [[ ! -d "$FLAKE_DIR/modules/hosts/$HOST" ]]; then
        echo "❌ Host '$HOST' not found in modules/hosts/. Please select from the list above."
        HOST=""
    fi
done

# 2. Target IP Selection
TARGET_IP=""
while [[ -z "$TARGET_IP" ]]; do
    read -p "Enter target IP address for $HOST: " TARGET_IP
    if [[ -z "$TARGET_IP" ]]; then
        echo "❌ Target IP cannot be empty."
    fi
done

# 3. Build Mode Selection
echo ""
echo "🏗️  Build location:"
echo "1) Build LOCALLY and copy to target (Recommended) [Default]"
echo "2) Build REMOTE-ly on target machine (Useful if local machine is low on resources/architecture difference)"
while true; do
    read -p "Select build mode [1-2] (default 1): " BUILD_CHOICE
    BUILD_CHOICE=${BUILD_CHOICE:-1}
    case "$BUILD_CHOICE" in
        1) REMOTE_BUILD=false; break ;;
        2) REMOTE_BUILD=true; break ;;
        *) echo "❌ Invalid selection. Please enter 1 or 2." ;;
    esac
done

# 4. Agenix Setting Selection
echo ""
echo "🔐 Agenix Secret Management:"
echo "1) ENABLED (Use encrypted secrets from solar-secrets) [Default]"
echo "2) DISABLED (Bypass secrets decryption for bootstrapping/testing)"
while true; do
    read -p "Select [1-2] (default 1): " AGENIX_CHOICE
    AGENIX_CHOICE=${AGENIX_CHOICE:-1}
    case "$AGENIX_CHOICE" in
        1) ENABLE_AGENIX=true; break ;;
        2) ENABLE_AGENIX=false; break ;;
        *) echo "❌ Invalid selection. Please enter 1 or 2." ;;
    esac
done

# 5. Secrets Directory Selection (if Agenix is Enabled)
if [[ "$ENABLE_AGENIX" == "true" ]]; then
    echo ""
    read -p "Enter path to the solar-secrets directory [default: ../solar-secrets]: " SECRETS_DIR_INPUT
    SECRETS_DIR="${SECRETS_DIR_INPUT:-../solar-secrets}"
    SECRETS_DIR=$(cd "$FLAKE_DIR" && cd "$SECRETS_DIR" 2>/dev/null && pwd || echo "$HOME/.solar-secrets")
fi

# 6. SSH Host Key Selection
echo ""
if [[ "$ENABLE_AGENIX" == "true" ]]; then
    echo "🔑 Host Key Setup (Agenix is ON):"
    echo "1) Generate a NEW SSH host key (Recommended for fresh install) [Default]"
    echo "2) Use EXISTING host key (Requires private key path)"
    while true; do
        read -p "Select [1-2] (default 1): " KEY_CHOICE
        KEY_CHOICE=${KEY_CHOICE:-1}
        case $KEY_CHOICE in
            1|2) break ;;
            *) echo "❌ Invalid selection. Please enter 1 or 2." ;;
        esac
    done
else
    echo "🔑 Host Key Setup (Agenix is OFF):"
    echo "1) Generate a NEW SSH host key [Default]"
    echo "2) Use EXISTING host key"
    echo "3) Skip SSH host key payload setup"
    while true; do
        read -p "Select [1-3] (default 1): " KEY_CHOICE
        KEY_CHOICE=${KEY_CHOICE:-1}
        case $KEY_CHOICE in
            1|2|3) break ;;
            *) echo "❌ Invalid selection. Please enter 1, 2, or 3." ;;
        esac
    done
fi

# 7. Existing Key Path (if Choice 2)
if [[ "$KEY_CHOICE" == "2" ]]; then
    while true; do
        read -p "Enter path to the EXISTING private SSH host key: " PRIV_KEY_PATH
        if [[ -f "$PRIV_KEY_PATH" ]]; then
            break
        else
            echo "❌ File not found at '$PRIV_KEY_PATH'. Please enter a valid path."
        fi
    done
fi

# 8. User Password Selection
echo ""
echo "👤 User Account Password:"
read -s -p "Enter custom password for user accounts (leave empty to use default 'solar'): " IMPERATIVE_PASSWORD
echo ""

# Print configuration summary
echo ""
echo "📝 Configuration Summary:"
echo "-----------------------------------"
echo "  Host:          $HOST"
echo "  Target IP:     $TARGET_IP"
echo "  Build Mode:    $( [ "$REMOTE_BUILD" == "true" ] && echo "Remote (on target)" || echo "Local" )"
echo "  Agenix:        $( [ "$ENABLE_AGENIX" == "true" ] && echo "ENABLED" || echo "DISABLED" )"
if [[ "$ENABLE_AGENIX" == "true" ]]; then
    echo "  Secrets Dir:   $SECRETS_DIR"
fi
case "$KEY_CHOICE" in
    1) echo "  Host Key:      Generate NEW SSH key" ;;
    2) echo "  Host Key:      Use EXISTING SSH key ($PRIV_KEY_PATH)" ;;
    3) echo "  Host Key:      SKIP payload setup" ;;
esac
echo "  Password:      $( [ -n "$IMPERATIVE_PASSWORD" ] && echo "[CONFIDENTIAL]" || echo "Use default ('solar')" )"
echo "-----------------------------------"
echo ""

read -p "Proceed with installation? (y/N): " CONFIRM_CHOICE
if [[ ! "$CONFIRM_CHOICE" =~ ^[Yy]$ ]]; then
    echo "❌ Installation aborted."
    exit 0
fi

# Handle Secrets Path & Dummy directory if agenix is disabled
if [[ "$ENABLE_AGENIX" == "false" ]]; then
    DUMMY_SECRETS_DIR="$TEMP_DIR/dummy-secrets"
    mkdir -p "$DUMMY_SECRETS_DIR"
    OVERRIDE_SECRETS_DIR="$DUMMY_SECRETS_DIR"
else
    OVERRIDE_SECRETS_DIR="$SECRETS_DIR"
fi

# Handle SSH Keys
HAS_KEY=false
if [[ "$KEY_CHOICE" == "1" ]]; then
    echo "🆕 Generating new SSH host key..."
    ssh-keygen -t ed25519 -f "$TEMP_DIR/ssh_host_ed25519_key" -N "" -C "root@$HOST"
    HAS_KEY=true

    if [[ "$ENABLE_AGENIX" == "true" ]]; then
        echo "📝 Updating solar-secrets with raw SSH public key..."
        mkdir -p "$SECRETS_DIR/hosts"
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
        git -C "$SECRETS_DIR" add -A 2>/dev/null || true
        git -C "$FLAKE_DIR" add "$FLAKE_DIR/rekeyed/$HOST" 2>/dev/null || true
    fi
elif [[ "$KEY_CHOICE" == "2" ]]; then
    echo "🔑 Preparing existing SSH host key..."
    cp "$PRIV_KEY_PATH" "$TEMP_DIR/ssh_host_ed25519_key"
    sed -i 's/\r//g' "$TEMP_DIR/ssh_host_ed25519_key"
    chmod 600 "$TEMP_DIR/ssh_host_ed25519_key"
    ssh-keygen -y -f "$TEMP_DIR/ssh_host_ed25519_key" > "$TEMP_DIR/ssh_host_ed25519_key.pub"
    HAS_KEY=true

    if [[ "$ENABLE_AGENIX" == "true" ]]; then
        mkdir -p "$SECRETS_DIR/hosts"
        cp "$TEMP_DIR/ssh_host_ed25519_key.pub" "$SECRETS_DIR/hosts/$HOST.pub"
        
        echo "🔐 Ensuring secrets are rekeyed for this host..."
        AGENIX_REKEY_PRIMARY_FLAKE_ROOT="$FLAKE_DIR" nix run --override-input solar-secrets "path:$SECRETS_DIR" --no-write-lock-file "$FLAKE_DIR#agenix-rekey-rekey"
        
        echo "🐙 Staging updates in both repositories..."
        git -C "$SECRETS_DIR" add -A 2>/dev/null || true
        git -C "$FLAKE_DIR" add "$FLAKE_DIR/rekeyed/$HOST" 2>/dev/null || true
    fi
fi

# Hashing password
if [[ -n "$IMPERATIVE_PASSWORD" ]]; then
    echo "🔒 Hashing custom password..."
    PASSWORD_HASH=$(nix run nixpkgs#mkpasswd -- -m sha-512 "$IMPERATIVE_PASSWORD")
else
    PASSWORD_HASH='$6$/Edi4zjoQYa81MQL$MD/BacUUKnb3jdHCnAzRG5s2Vh7KUIYh4s0h/5SQzMLVpbJ7T6XKCvYMuMZ2Sqt91quxmHATBEzkuyQKzQ/K5/'
fi

# Prepare nixos-anywhere extra-files
echo "📦 Preparing extra-files payload..."
PAYLOAD_DIR="$TEMP_DIR/payload"

mkpath() {
    mkdir -p "$1"
    chmod "$2" "$1"
}

# Base directories
mkpath "$PAYLOAD_DIR" 755
mkpath "$PAYLOAD_DIR/etc" 755

# Write password file
echo "$PASSWORD_HASH" > "$PAYLOAD_DIR/etc/user-password"
chmod 600 "$PAYLOAD_DIR/etc/user-password"

# Mirror password file to /persist
mkpath "$PAYLOAD_DIR/persist" 755
mkpath "$PAYLOAD_DIR/persist/etc" 755
echo "$PASSWORD_HASH" > "$PAYLOAD_DIR/persist/etc/user-password"
chmod 600 "$PAYLOAD_DIR/persist/etc/user-password"

if [[ "$HAS_KEY" == "true" ]]; then
    mkpath "$PAYLOAD_DIR/etc/ssh" 755
    cp "$TEMP_DIR/ssh_host_ed25519_key" "$PAYLOAD_DIR/etc/ssh/"
    cp "$TEMP_DIR/ssh_host_ed25519_key.pub" "$PAYLOAD_DIR/etc/ssh/"
    chmod 600 "$PAYLOAD_DIR/etc/ssh/ssh_host_ed25519_key"
    chmod 644 "$PAYLOAD_DIR/etc/ssh/ssh_host_ed25519_key.pub"

    # Persistence location (Mirror keys so they survive reboot on tmpfs-root systems)
    echo "🔗 Mirroring keys to /persist/etc/ssh for persistence compatibility..."
    mkpath "$PAYLOAD_DIR/persist/etc/ssh" 755
    cp "$TEMP_DIR/ssh_host_ed25519_key" "$PAYLOAD_DIR/persist/etc/ssh/"
    cp "$TEMP_DIR/ssh_host_ed25519_key.pub" "$PAYLOAD_DIR/persist/etc/ssh/"
    chmod 600 "$PAYLOAD_DIR/persist/etc/ssh/ssh_host_ed25519_key"
    chmod 644 "$PAYLOAD_DIR/persist/etc/ssh/ssh_host_ed25519_key.pub"
fi

EXTRA_FILES_ARG=(--extra-files "$PAYLOAD_DIR")

# Build and Execute
echo "🏗️ Building system and disko script..."

if [[ "$REMOTE_BUILD" == "true" ]]; then
    echo "📡 Phase 1: kexec into target to prepare build environment..."
    if ! nix run github:nix-community/nixos-anywhere -- --print-build-logs --flake ".#$HOST" --phases kexec "root@$TARGET_IP"; then
        echo "❌ Phase 1 (kexec) failed. Please check the logs above."
        exit 1
    fi

    echo "⏳ Waiting for target to become reachable again..."
    while ! nc -z -w 2 "$TARGET_IP" 22 2>/dev/null; do
        echo -n "."
        sleep 2
    done
    echo " Online!"

    echo "🔑 Authorizing your SSH key on the target installer for the build phase..."
    echo "You may be prompted for the target's root password (usually 'nixos')."
    ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "root@$TARGET_IP"

    echo "🏗️ Phase 2: Building closures ON the target machine..."
    export NIX_SSHOPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
    
    sudo mkdir -p /root/.ssh
    sudo ssh-keyscan -H "$TARGET_IP" | sudo tee /root/.ssh/known_hosts > /dev/null

    DISKO_PATH=$(sudo env NIX_SSHOPTS="$NIX_SSHOPTS" HOME=/root nix build ".#nixosConfigurations.$HOST.config.system.build.diskoScript" \
        --override-input solar-secrets "path:$OVERRIDE_SECRETS_DIR" \
        --builders "ssh://root@$TARGET_IP" --max-jobs 0 \
        --no-link --print-out-paths --no-write-lock-file)
    
    SYSTEM_PATH=$(sudo env NIX_SSHOPTS="$NIX_SSHOPTS" HOME=/root nix build ".#nixosConfigurations.$HOST.config.system.build.toplevel" \
        --override-input solar-secrets "path:$OVERRIDE_SECRETS_DIR" \
        --builders "ssh://root@$TARGET_IP" --max-jobs 0 \
        --no-link --print-out-paths --no-write-lock-file)

    echo "📡 Phase 3: Executing disko and installation..."
    nix run github:nix-community/nixos-anywhere -- \
        --phases disko,install,reboot \
        --store-paths "$DISKO_PATH" "$SYSTEM_PATH" \
        "${EXTRA_FILES_ARG[@]}" \
        "root@$TARGET_IP"
else
    echo "🏗️ Building closures locally..."
    DISKO_PATH=$(nix build ".#nixosConfigurations.$HOST.config.system.build.diskoScript" --override-input solar-secrets "path:$OVERRIDE_SECRETS_DIR" --no-link --print-out-paths --no-write-lock-file)
    SYSTEM_PATH=$(nix build ".#nixosConfigurations.$HOST.config.system.build.toplevel" --override-input solar-secrets "path:$OVERRIDE_SECRETS_DIR" --no-link --print-out-paths --no-write-lock-file)

    echo "📡 Executing nixos-anywhere..."
    echo "If you set a password on the live USB, nixos-anywhere will prompt for it now."
    nix run github:nix-community/nixos-anywhere -- \
        --store-paths "$DISKO_PATH" "$SYSTEM_PATH" \
        "${EXTRA_FILES_ARG[@]}" \
        "root@$TARGET_IP"
fi

echo ""
echo "✅ Installation of $HOST initiated!"
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
