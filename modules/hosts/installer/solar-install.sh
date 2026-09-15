#!/usr/bin/env bash
set -Eeuo pipefail

# Colors
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Trap unexpected errors and keep the terminal open for debugging
on_exit() {
    local exit_code=$1
    local line_no=$2
    if [[ $exit_code -ne 0 ]]; then
        echo -e "\n${RED}${BOLD}❌ Installation failed at line $line_no (Exit code: $exit_code)${NC}"
        echo -e "${YELLOW}Review the errors above. The terminal will remain open for debugging.${NC}"
        read -r -p "Press Enter to exit..." dummy || true
    fi
}
trap 'on_exit $? $LINENO' EXIT

echo -e "${CYAN}${BOLD}"
echo "  ☀️  ========================================================="
echo "      SOLAR ON-DEVICE SYSTEM INSTALLER"
echo "  ========================================================="
echo -e "${NC}"

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}❌ This installer must be run as root (or via sudo).${NC}"
    echo "Please re-run with: sudo solar-install"
    exit 1
fi

# Ensure git safe directory for all repositories
git config --global --add safe.directory "*" 2>/dev/null || true

# Ensure nix config has experimental features enabled for root
mkdir -p ~/.config/nix
if [[ ! -f ~/.config/nix/nix.conf ]] || ! grep -q "nix-command" ~/.config/nix/nix.conf; then
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf 2>/dev/null || true
fi

# 1. Locate / Prepare Flake Repository
echo -e "${BOLD}📁 Solar Configuration Source:${NC}"
echo "  1) Pull latest from GitHub (Recommended - apollo-sudo767/solar) [Default]"
echo "  2) Use bundled offline repository (/home/nixos/solar)"
echo "  3) Use current directory ($PWD)"
read -r -p "Select source [1-3] (default 1): " REPO_CHOICE
REPO_CHOICE="${REPO_CHOICE:-1}"

FLAKE_DIR="/tmp/solar"
case "$REPO_CHOICE" in
    2)
        if [[ -d "/home/nixos/solar" ]]; then
            echo -e "${BLUE}📁 Copying bundled repository to /tmp/solar...${NC}"
            rm -rf /tmp/solar
            cp -r /home/nixos/solar /tmp/solar
            chmod -R u+w /tmp/solar
        else
            echo -e "${YELLOW}Bundled repo not found, falling back to GitHub...${NC}"
            REPO_CHOICE="1"
        fi
        ;;
    3)
        if [[ -f "./flake.nix" ]]; then
            echo -e "${BLUE}📁 Using current directory ($PWD)...${NC}"
            FLAKE_DIR="$PWD"
        else
            echo -e "${YELLOW}No flake.nix in current directory, falling back to GitHub...${NC}"
            REPO_CHOICE="1"
        fi
        ;;
esac

if [[ "$REPO_CHOICE" == "1" ]]; then
    echo -e "${BLUE}🌐 Fetching latest Solar repository from GitHub...${NC}"
    if [[ -d "/tmp/solar/.git" ]]; then
        echo "Updating existing clone in /tmp/solar..."
        git -C /tmp/solar fetch origin 2>/dev/null || true
        git -C /tmp/solar reset --hard origin/main 2>/dev/null || true
    else
        rm -rf /tmp/solar
        git clone https://github.com/Apollo-sudo767/solar.git /tmp/solar
    fi
    FLAKE_DIR="/tmp/solar"
fi

# Auto-reexec newer installer script if repository has one and we haven't re-executed yet
if [[ -z "${SOLAR_INSTALL_REEXEC:-}" && -f "$FLAKE_DIR/modules/hosts/installer/solar-install.sh" ]]; then
    export SOLAR_INSTALL_REEXEC=1
    echo -e "${GREEN}✓ Launching updated solar-install from repository...${NC}\n"
    exec bash "$FLAKE_DIR/modules/hosts/installer/solar-install.sh" "$@"
fi

# Ensure FLAKE_DIR is initialized as a git repository so Nix Flakes can evaluate it
if [[ ! -d "$FLAKE_DIR/.git" ]]; then
    echo -e "${BLUE}🔧 Initializing git repository in $FLAKE_DIR...${NC}"
    git -C "$FLAKE_DIR" init >/dev/null 2>&1 || true
    git -C "$FLAKE_DIR" add -A >/dev/null 2>&1 || true
    git -C "$FLAKE_DIR" -c user.name="Solar" -c user.email="solar@localhost" commit -m "solar install staging" >/dev/null 2>&1 || true
fi

echo -e "${GREEN}✓ Using Solar repository:${NC} $FLAKE_DIR\n"

# 2. Host Selection
HOSTS=()
for dir in "$FLAKE_DIR/modules/hosts"/*; do
    if [[ -d "$dir" ]]; then
        h=$(basename "$dir")
        if [[ "$h" != "shared" && "$h" != "installer" ]]; then
            # Exclude macOS / Darwin hosts (e.g. phobos)
            if grep -q "darwin" "$dir/default.nix" 2>/dev/null; then
                continue
            fi
            HOSTS+=("$h")
        fi
    fi
done

if [[ ${#HOSTS[@]} -eq 0 ]]; then
    echo -e "${RED}❌ No Linux hosts found in $FLAKE_DIR/modules/hosts/${NC}"
    exit 1
fi

echo -e "${BOLD}Select the target host configuration to install on this machine:${NC}"
for i in "${!HOSTS[@]}"; do
    printf "  ${CYAN}%2d)${NC} %s\n" $((i + 1)) "${HOSTS[$i]}"
done
echo ""

SELECTED_HOST=""
while [[ -z "$SELECTED_HOST" ]]; do
    read -r -p "Enter number [1-${#HOSTS[@]}]: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#HOSTS[@]} )); then
        SELECTED_HOST="${HOSTS[$((choice - 1))]}"
    else
        echo -e "${RED}Invalid selection. Enter a number between 1 and ${#HOSTS[@]}.${NC}"
    fi
done

HOST_DIR="$FLAKE_DIR/modules/hosts/$SELECTED_HOST"
echo -e "\n${GREEN}✓ Target host:${NC} ${BOLD}$SELECTED_HOST${NC}\n"

# 3. Block Devices Inspection
echo -e "${BOLD}Detected Storage Devices:${NC}"
lsblk -o NAME,SIZE,TYPE,MODEL,TRAN,MOUNTPOINTS
echo ""

# 4. Generate Hardware Configuration Option
echo -e "${BOLD}Hardware Configuration:${NC}"
read -r -p "Generate fresh hardware-configuration.nix from this machine? (Y/n): " GEN_HW
GEN_HW="${GEN_HW:-y}"
if [[ "$GEN_HW" =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}⚙️  Generating hardware configuration...${NC}"
    mkdir -p /tmp/hw-gen
    nixos-generate-config --no-filesystems --dir /tmp/hw-gen
    cp /tmp/hw-gen/hardware-configuration.nix "$HOST_DIR/hardware-configuration.nix"
    git -C "$FLAKE_DIR" add "$HOST_DIR/hardware-configuration.nix" >/dev/null 2>&1 || true
    echo -e "${GREEN}✓ hardware-configuration.nix updated and staged for $SELECTED_HOST.${NC}\n"
fi

# 5. User Password Setup
echo -e "${BOLD}User Account Setup:${NC}"
read -s -r -p "Enter password for user accounts (press Enter for default 'solar'): " USER_PASS
echo ""
USER_PASS="${USER_PASS:-solar}"
PASSWORD_HASH=$(mkpasswd -m sha-512 "$USER_PASS")

# 6. Agenix / Secrets Mode
echo -e "\n${BOLD}Secrets Management:${NC}"
echo "1) Bypass secrets (Standalone / Bootstrapping) [Default]"
echo "2) Use solar-secrets repository"
read -r -p "Select [1-2] (default 1): " SECRETS_CHOICE
SECRETS_CHOICE="${SECRETS_CHOICE:-1}"

OVERRIDE_SECRETS_ARG=()
SECRETS_DIR=""
if [[ "$SECRETS_CHOICE" == "2" ]]; then
    read -r -p "Enter path to solar-secrets [default /home/nixos/solar-secrets]: " SECRETS_PATH
    SECRETS_PATH="${SECRETS_PATH:-/home/nixos/solar-secrets}"
    if [[ -d "$SECRETS_PATH" ]]; then
        SECRETS_DIR="$SECRETS_PATH"
        OVERRIDE_SECRETS_ARG=(--override-input solar-secrets "path:$SECRETS_PATH")
        echo -e "${BLUE}🔒 Locking solar-secrets to: $SECRETS_PATH...${NC}"
        nix --extra-experimental-features "nix-command flakes" flake lock --override-input solar-secrets "path:$SECRETS_PATH" "$FLAKE_DIR"
    else
        echo -e "${YELLOW}Directory not found, proceeding with dummy secrets bypass.${NC}"
        DUMMY_DIR=$(mktemp -d)
        SECRETS_DIR="$DUMMY_DIR"
        OVERRIDE_SECRETS_ARG=(--override-input solar-secrets "path:$DUMMY_DIR")
        echo -e "${BLUE}🔒 Locking dummy secrets in flake...${NC}"
        nix --extra-experimental-features "nix-command flakes" flake lock --override-input solar-secrets "path:$DUMMY_DIR" "$FLAKE_DIR"
    fi
else
    DUMMY_DIR=$(mktemp -d)
    SECRETS_DIR="$DUMMY_DIR"
    OVERRIDE_SECRETS_ARG=(--override-input solar-secrets "path:$DUMMY_DIR")
    echo -e "${BLUE}🔒 Locking dummy secrets in flake...${NC}"
    nix --extra-experimental-features "nix-command flakes" flake lock --override-input solar-secrets "path:$DUMMY_DIR" "$FLAKE_DIR"
fi
git -C "$FLAKE_DIR" add flake.lock 2>/dev/null || true

# 7. Storage Preparation & Cleanup
HAS_DISKO=true
if grep -qE "disko\.enable\s*=\s*false" "$HOST_DIR/default.nix" 2>/dev/null; then
    HAS_DISKO=false
fi

# Clean up any active mounts, swap, and LUKS device-mapper locks
echo -e "\n${BLUE}🧹 Performing pre-flight storage cleanup (unmounting /mnt, disabling swap)...${NC}"
umount -R /mnt 2>/dev/null || true
swapoff -a 2>/dev/null || true

# Close any active dm-crypt devices
for dev in /dev/mapper/crypted-*; do
    if [[ -e "$dev" ]]; then
        echo "Closing active crypt device: $(basename "$dev")"
        cryptsetup close "$(basename "$dev")" 2>/dev/null || true
    fi
done

if [[ "$HAS_DISKO" == "true" ]]; then
    echo -e "\n${RED}${BOLD}⚠️  WARNING: Target drives configured in Disko for '$SELECTED_HOST' will be COMPLETELY WIPED!${NC}"
    echo -e "All existing partitions and data on target disk(s) will be destroyed."
    read -r -p "Type 'yes' to proceed with Disko partitioning and installation: " CONFIRM
    if [[ "$CONFIRM" != "yes" ]]; then
        echo "Installation aborted by user."
        exit 0
    fi

    # Stage all changes in git so Disko and Nix Flakes see them
    git -C "$FLAKE_DIR" add -A 2>/dev/null || true

    # 8. Run Disko
    echo -e "\n${CYAN}🚀 Phase 1/3: Partitioning and mounting storage via Disko...${NC}"
    disko --mode destroy,format,mount --yes-wipe-all-disks --flake "$FLAKE_DIR#$SELECTED_HOST"

    # Verify that Disko mounted the root filesystem to /mnt
    if ! findmnt /mnt >/dev/null 2>&1; then
        echo -e "${RED}❌ Disko failed to mount target filesystem to /mnt. Aborting.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Storage partitioned and mounted at /mnt successfully.${NC}"
else
    echo -e "\n${YELLOW}ℹ️  Notice: Disko is disabled for '$SELECTED_HOST'.${NC}"
    if ! findmnt /mnt >/dev/null 2>&1; then
        echo -e "${RED}❌ No filesystem mounted at /mnt. Please mount target storage to /mnt first.${NC}"
        exit 1
    fi
    echo -e "\n${CYAN}🚀 Phase 1/3: Storage verified at /mnt (manual layout). Skipping Disko...${NC}"
fi

# 8b. SSH Host Key Provisioning
echo -e "\n${CYAN}🔑 Provisioning SSH host keys for $SELECTED_HOST...${NC}"
mkdir -p /mnt/persist/etc/ssh /mnt/etc/ssh

if [[ -n "$SECRETS_DIR" && -f "$SECRETS_DIR/keys/$SELECTED_HOST/ssh_host_ed25519_key" ]]; then
    echo -e "${GREEN}✓ Found pre-generated host key in secrets repository for '$SELECTED_HOST'. Provisioning...${NC}"
    cp "$SECRETS_DIR/keys/$SELECTED_HOST/ssh_host_ed25519_key"* /mnt/persist/etc/ssh/ 2>/dev/null || true
    cp "$SECRETS_DIR/keys/$SELECTED_HOST/ssh_host_ed25519_key"* /mnt/etc/ssh/ 2>/dev/null || true
elif [[ ! -f "/mnt/persist/etc/ssh/ssh_host_ed25519_key" && ! -f "/mnt/etc/ssh/ssh_host_ed25519_key" ]]; then
    echo -e "${BLUE}🔑 Generating fresh persistent SSH host key for $SELECTED_HOST...${NC}"
    ssh-keygen -t ed25519 -f /mnt/persist/etc/ssh/ssh_host_ed25519_key -N "" -C "root@$SELECTED_HOST"
    cp /mnt/persist/etc/ssh/ssh_host_ed25519_key* /mnt/etc/ssh/ 2>/dev/null || true
fi

chmod 600 /mnt/persist/etc/ssh/ssh_host_ed25519_key /mnt/etc/ssh/ssh_host_ed25519_key 2>/dev/null || true
chmod 644 /mnt/persist/etc/ssh/ssh_host_ed25519_key.pub /mnt/etc/ssh/ssh_host_ed25519_key.pub 2>/dev/null || true

if [[ -f "/mnt/persist/etc/ssh/ssh_host_ed25519_key.pub" ]]; then
    echo -e "${GREEN}✓ Host public key for $SELECTED_HOST: ${BOLD}$(cat /mnt/persist/etc/ssh/ssh_host_ed25519_key.pub)${NC}"
fi

# Stage Initial User Password before activation
echo -e "\n${CYAN}🔑 Staging credentials before NixOS install...${NC}"
mkdir -p /mnt/etc /mnt/persist/etc
if [ -n "$PASSWORD_HASH" ]; then
    echo "$PASSWORD_HASH" > /mnt/etc/user-password
    chmod 600 /mnt/etc/user-password
    if [[ -d "/mnt/persist" ]]; then
        echo "$PASSWORD_HASH" > /mnt/persist/etc/user-password
        chmod 600 /mnt/persist/etc/user-password
        echo -e "${GREEN}✓ Mirrored user password to /persist/etc/user-password${NC}"
    fi
fi

# 9. Run NixOS Install
echo -e "\n${CYAN}🚀 Phase 2/3: Installing NixOS system ($SELECTED_HOST)...${NC}"
git -C "$FLAKE_DIR" add -A 2>/dev/null || true
nixos-install --flake "$FLAKE_DIR#$SELECTED_HOST" "${OVERRIDE_SECRETS_ARG[@]}" --no-root-password

# 10. Finalize User Credentials
echo -e "\n${CYAN}🚀 Phase 3/3: Finalizing system configuration...${NC}"
PRIMARY_USER=$(grep -oE 'usernames\s*=\s*\[\s*"[^"]+"' "$HOST_DIR/default.nix" 2>/dev/null | head -n1 | sed -E 's/.*"([^"]+)".*/\1/' || echo "apollo")
PRIMARY_USER="${PRIMARY_USER:-apollo}"
if [ -n "$PASSWORD_HASH" ]; then
    nixos-enter --root /mnt -c "echo '$PRIMARY_USER:$PASSWORD_HASH' | chpasswd -e" 2>/dev/null || true
    echo -e "${GREEN}✓ Account '$PRIMARY_USER' password initialized in /etc/shadow${NC}"
fi

sync
echo -e "\n${GREEN}${BOLD}🎉 Installation of $SELECTED_HOST completed successfully!${NC}"
echo "========================================================="
echo "The system is installed on disk and ready to boot."
read -r -p "Reboot now? (y/N): " DO_REBOOT
if [[ "$DO_REBOOT" =~ ^[Yy]$ ]]; then
    reboot
fi
