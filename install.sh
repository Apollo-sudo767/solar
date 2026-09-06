#!/usr/bin/env bash

# Exit on error
set -e

# Configuration
FLAKE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_DIR=$(mktemp -d)

# Ensure cleanup on exit
on_exit() {
    local exit_code=$1
    local line_no=$2
    rm -rf "$TEMP_DIR" 2>/dev/null || true
    if [[ $exit_code -ne 0 ]]; then
        echo -e "\n\033[0;31m❌ Installation script failed at line $line_no (Exit code: $exit_code)\033[0m"
    fi
}
trap 'on_exit $? $LINENO' EXIT

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

# 3. Build Mode & Target State Selection
echo ""
LOCAL_OS=$(uname -s)
TARGET_SYSTEM=$(grep -oE 'system\s*=\s*"[^"]+"' "$FLAKE_DIR/modules/hosts/$HOST/default.nix" 2>/dev/null | head -n1 | sed -E 's/.*"([^"]+)".*/\1/' || echo "x86_64-linux")

if [[ "$LOCAL_OS" == "Darwin" && "$TARGET_SYSTEM" =~ linux ]]; then
    echo "⚠️  Detected macOS host ($LOCAL_OS) targeting Linux ($TARGET_SYSTEM)."
    echo "   Local build requires a Linux remote builder. Defaulting build mode to Remote (on target)."
    REMOTE_BUILD=true
else
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
fi

echo ""
read -p "Is target already booted into a NixOS / Solar Live USB? (Y/n): " IN_INSTALLER
IN_INSTALLER=${IN_INSTALLER:-y}
if [[ "$IN_INSTALLER" =~ ^[Yy]$ ]]; then
    PHASES_ARG=(--phases disko,install,reboot)
else
    PHASES_ARG=(--phases kexec,disko,install,reboot)
fi

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
echo "🏗️ Initiating nixos-anywhere deployment for $HOST to $TARGET_IP..."

BUILD_ARGS=()
if [[ "$REMOTE_BUILD" == "true" ]]; then
    BUILD_ARGS=(--build-on-remote)
fi

OVERRIDE_SECRETS_ARGS=(--override-input solar-secrets "path:$OVERRIDE_SECRETS_DIR")

echo "📡 Executing nixos-anywhere (${PHASES_ARG[*]} via $( [ "$REMOTE_BUILD" == "true" ] && echo "remote build" || echo "local build" ))..."
nix run github:nix-community/nixos-anywhere -- \
    --flake "$FLAKE_DIR#$HOST" \
    "${BUILD_ARGS[@]}" \
    "${OVERRIDE_SECRETS_ARGS[@]}" \
    "${PHASES_ARG[@]}" \
    "${EXTRA_FILES_ARG[@]}" \
    "root@$TARGET_IP"

echo ""
echo "✅ Installation of $HOST initiated!"
echo "----------------------------------------------------------------------"
echo "🛠️  MANUAL POST-INSTALL STEPS"
echo "----------------------------------------------------------------------"
echo "1. Wait for the machine to reboot and enter your LUKS passphrase."
echo "2. Log in (via SSH or physically)."
echo "3. (Optional) Enroll TPM 2.0 tamper-proof auto-unlock on encrypted drives:"
echo "   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2"
echo ""
echo "4. If using Secure Boot, run the following commands as root:"
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
echo "   # Finalize"
echo "   sync"
echo "   reboot"
echo "----------------------------------------------------------------------"
