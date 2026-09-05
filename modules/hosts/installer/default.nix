{
  meta = {
    system = "x86_64-linux";
    stable = false;
    useSecrets = false;
  };

  module =
    {
      config,
      lib,
      pkgs,
      inputs,
      ...
    }:
    let
      solarInstallScript = pkgs.writeShellScriptBin "solar-install" ''
        #!/usr/bin/env bash
        set -euo pipefail

        # Colors
        BOLD='\033[1m'
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[1;33m'
        BLUE='\033[0;34m'
        CYAN='\033[0;36m'
        NC='\033[0m'

        echo -e "''${CYAN}''${BOLD}"
        echo "  ☀️  ====================================================="
        echo "      SOLAR ON-DEVICE SYSTEM INSTALLER"
        echo "  ========================================================="
        echo -e "''${NC}"

        if [[ $EUID -ne 0 ]]; then
            echo -e "''${RED}❌ This installer must be run as root (or via sudo).''${NC}"
            echo "Please re-run with: sudo solar-install"
            exit 1
        fi

        # 1. Locate Flake Repository
        FLAKE_DIR=""
        if [[ -d "/home/nixos/solar" && -f "/home/nixos/solar/flake.nix" ]]; then
            FLAKE_DIR="/home/nixos/solar"
        elif [[ -d "/etc/solar" && -f "/etc/solar/flake.nix" ]]; then
            # Copy to writable directory
            echo -e "''${BLUE}📁 Copying Solar repository to writable workspace in /tmp/solar...''${NC}"
            mkdir -p /tmp/solar
            cp -r /etc/solar/. /tmp/solar/
            chmod -R u+w /tmp/solar
            FLAKE_DIR="/tmp/solar"
        elif [[ -f "./flake.nix" ]]; then
            FLAKE_DIR="$PWD"
        else
            echo -e "''${YELLOW}⚠️  Local Solar repository not found in standard paths.''${NC}"
            echo -e "''${BLUE}Cloning latest Solar from GitHub...''${NC}"
            git clone https://github.com/Apollo-sudo767/solar.git /tmp/solar
            FLAKE_DIR="/tmp/solar"
        fi

        echo -e "''${GREEN}✓ Using Solar repository:''${NC} $FLAKE_DIR\n"

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

        if [[ ''${#HOSTS[@]} -eq 0 ]]; then
            echo -e "''${RED}❌ No hosts found in $FLAKE_DIR/modules/hosts/''${NC}"
            exit 1
        fi

        echo -e "''${BOLD}Select the target host configuration to install on this machine:''${NC}"
        for i in "''${!HOSTS[@]}"; do
            printf "  ''${CYAN}%2d)''${NC} %s\n" $((i + 1)) "''${HOSTS[$i]}"
        done
        echo ""

        SELECTED_HOST=""
        while [[ -z "$SELECTED_HOST" ]]; do
            read -r -p "Enter number [1-''${#HOSTS[@]}]: " choice
            if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ''${#HOSTS[@]} )); then
                SELECTED_HOST="''${HOSTS[$((choice - 1))]}"
            else
                echo -e "''${RED}Invalid selection. Enter a number between 1 and ''${#HOSTS[@]}.''${NC}"
            fi
        done

        HOST_DIR="$FLAKE_DIR/modules/hosts/$SELECTED_HOST"
        echo -e "\n''${GREEN}✓ Target host:''${NC} ''${BOLD}$SELECTED_HOST''${NC}\n"

        # 3. Block Devices Inspection
        echo -e "''${BOLD}Detected Storage Devices:''${NC}"
        lsblk -o NAME,SIZE,TYPE,MODEL,TRAN,MOUNTPOINTS
        echo ""

        # 4. Generate Hardware Configuration Option
        echo -e "''${BOLD}Hardware Configuration:''${NC}"
        read -r -p "Generate fresh hardware-configuration.nix from this machine? (Y/n): " GEN_HW
        GEN_HW="''${GEN_HW:-y}"
        if [[ "$GEN_HW" =~ ^[Yy]$ ]]; then
            echo -e "''${BLUE}⚙️  Generating hardware configuration...''${NC}"
            mkdir -p /tmp/hw-gen
            nixos-generate-config --no-filesystems --dir /tmp/hw-gen
            if [[ ! -w "$HOST_DIR/hardware-configuration.nix" ]]; then
                mkdir -p /tmp/solar-workspace
                cp -r "$FLAKE_DIR/." /tmp/solar-workspace/
                chmod -R u+w /tmp/solar-workspace
                FLAKE_DIR="/tmp/solar-workspace"
                HOST_DIR="$FLAKE_DIR/modules/hosts/$SELECTED_HOST"
            fi
            cp /tmp/hw-gen/hardware-configuration.nix "$HOST_DIR/hardware-configuration.nix"
            echo -e "''${GREEN}✓ hardware-configuration.nix updated for $SELECTED_HOST.''${NC}\n"
        fi

        # 5. User Password Setup
        echo -e "''${BOLD}User Account Setup:''${NC}"
        read -s -r -p "Enter password for user accounts (press Enter for default 'solar'): " USER_PASS
        echo ""
        USER_PASS="''${USER_PASS:-solar}"
        PASSWORD_HASH=$(mkpasswd -m sha-512 "$USER_PASS")

        # 6. Agenix / Secrets Mode
        echo -e "\n''${BOLD}Secrets Management:''${NC}"
        echo "1) Bypass secrets (Standalone / Bootstrapping) [Default]"
        echo "2) Use solar-secrets repository"
        read -r -p "Select [1-2] (default 1): " SECRETS_CHOICE
        SECRETS_CHOICE="''${SECRETS_CHOICE:-1}"

        OVERRIDE_SECRETS_ARG=()
        if [[ "$SECRETS_CHOICE" == "2" ]]; then
            read -r -p "Enter path to solar-secrets [default /home/nixos/solar-secrets]: " SECRETS_PATH
            SECRETS_PATH="''${SECRETS_PATH:-/home/nixos/solar-secrets}"
            if [[ -d "$SECRETS_PATH" ]]; then
                OVERRIDE_SECRETS_ARG=(--override-input solar-secrets "path:$SECRETS_PATH")
            else
                echo -e "''${YELLOW}Directory not found, proceeding with dummy secrets bypass.''${NC}"
                DUMMY_DIR=$(mktemp -d)
                DUMMY_DIR=$(realpath "$DUMMY_DIR" 2>/dev/null || echo "$DUMMY_DIR")
                OVERRIDE_SECRETS_ARG=(--override-input solar-secrets "path:$DUMMY_DIR")
            fi
        else
            DUMMY_DIR=$(mktemp -d)
            DUMMY_DIR=$(realpath "$DUMMY_DIR" 2>/dev/null || echo "$DUMMY_DIR")
            OVERRIDE_SECRETS_ARG=(--override-input solar-secrets "path:$DUMMY_DIR")
        fi

        # 7. Storage Preparation (Disko or Manual Layout)
        HAS_DISKO=true
        if grep -qE "disko\.enable\s*=\s*false" "$HOST_DIR/default.nix" 2>/dev/null; then
            HAS_DISKO=false
        fi

        if [[ "$HAS_DISKO" == "true" ]]; then
            echo -e "\n''${RED}''${BOLD}⚠️  WARNING: Target drives configured in Disko for '$SELECTED_HOST' will be COMPLETELY WIPED!''${NC}"
            echo -e "All existing partitions and data will be destroyed."
            read -r -p "Type 'yes' to proceed with Disko partitioning and installation: " CONFIRM
            if [[ "$CONFIRM" != "yes" ]]; then
                echo "Installation aborted."
                exit 0
            fi

            # 8. Run Disko
            echo -e "\n''${CYAN}🚀 Phase 1/3: Partitioning and mounting storage via Disko...''${NC}"
            disko --mode disko --flake "$FLAKE_DIR#$SELECTED_HOST" "''${OVERRIDE_SECRETS_ARG[@]}"
        else
            echo -e "\n''${YELLOW}ℹ️  Notice: Disko is not configured for '$SELECTED_HOST' (disko.enable = false).''${NC}"
            echo -e "This host expects filesystems defined via hardware-configuration.nix or manual mounts."

            if findmnt /mnt >/dev/null 2>&1; then
                echo -e "''${GREEN}✓ Active root filesystem mount detected at /mnt.''${NC}"
                read -r -p "Install $SELECTED_HOST directly into currently mounted /mnt? (Y/n): " PROCEED_MOUNT
                PROCEED_MOUNT="''${PROCEED_MOUNT:-y}"
                if [[ ! "$PROCEED_MOUNT" =~ ^[Yy]$ ]]; then
                    echo "Installation aborted."
                    exit 0
                fi
            else
                echo -e "\n''${RED}⚠️  No filesystem is mounted at /mnt.''${NC}"
                echo "To install $SELECTED_HOST without Disko, please prepare storage:"
                echo "  1) Partition and format drives (e.g. using GParted or parted/fdisk)"
                echo "  2) Mount root filesystem to /mnt (e.g. mount /dev/... /mnt)"
                echo "  3) Mount boot/ESP partition to /mnt/boot (e.g. mount /dev/... /mnt/boot)"
                echo ""
                if command -v gparted &>/dev/null && [[ -n "$DISPLAY" ]]; then
                    read -r -p "Launch GParted now? (y/N): " LAUNCH_GP
                    if [[ "$LAUNCH_GP" =~ ^[Yy]$ ]]; then
                        gparted &
                    fi
                fi
                echo -e "Mount your target partitions to /mnt, then press Enter to continue (or Ctrl+C to exit)..."
                read -r
                if ! findmnt /mnt >/dev/null 2>&1; then
                    echo -e "''${RED}❌ No filesystem mounted at /mnt. Aborting installation.''${NC}"
                    exit 1
                fi
            fi
            echo -e "\n''${CYAN}🚀 Phase 1/3: Storage verified at /mnt (manual layout). Skipping Disko...''${NC}"
        fi

        # 9. Run NixOS Install
        echo -e "\n''${CYAN}🚀 Phase 2/3: Installing NixOS system ($SELECTED_HOST)...''${NC}"
        nixos-install --flake "$FLAKE_DIR#$SELECTED_HOST" "''${OVERRIDE_SECRETS_ARG[@]}" --no-root-password

        # 10. Write Initial User Password and Persistence
        echo -e "\n''${CYAN}🚀 Phase 3/3: Finalizing system configuration...''${NC}"
        mkdir -p /mnt/etc
        echo "$PASSWORD_HASH" > /mnt/etc/user-password
        chmod 600 /mnt/etc/user-password

        if [[ -d "/mnt/persist" ]]; then
            mkdir -p /mnt/persist/etc
            echo "$PASSWORD_HASH" > /mnt/persist/etc/user-password
            chmod 600 /mnt/persist/etc/user-password
            echo -e "''${GREEN}✓ Mirrored user password to /persist/etc/user-password''${NC}"
        fi

        sync
        echo -e "\n''${GREEN}''${BOLD}🎉 Installation of $SELECTED_HOST completed successfully!''${NC}"
        echo "========================================================="
        echo "The system is installed on disk and ready to boot."
        read -r -p "Reboot now? (y/N): " DO_REBOOT
        if [[ "$DO_REBOOT" =~ ^[Yy]$ ]]; then
            reboot
        fi
      '';
    in
    {
      imports = [
        ./hardware-configuration.nix
        "${inputs.nixpkgs-unstable}/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix"
      ];

      system.stateVersion = "26.11";

      # Explicitly disable non-ISO core features
      myFeatures.core = {
        system = {
          core-branch.enable = false;
          disko.enable = false;
          preservation.enable = false;
          users.enable = false;
        };
        boot.boot.enable = false;
        security.agenix.enable = false;
      };

      networking.hostName = "installer";

      # Networking via NetworkManager (disable conflicting wireless wpa_supplicant)
      networking.networkmanager.enable = true;
      networking.wireless.enable = lib.mkForce false;

      # Graphical Desktop: Lightweight XFCE for universal hardware compatibility
      services.xserver = {
        enable = true;
        desktopManager.xfce.enable = true;
      };
      services.displayManager.defaultSession = "xfce";
      services.displayManager.autoLogin = {
        enable = true;
        user = "nixos";
      };

      # Console auto-login on virtual terminals
      services.getty.autologinUser = "nixos";

      # SSH Server with root and user access
      services.openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "yes";
          PasswordAuthentication = true;
        };
      };

      users.users.nixos = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
          "audio"
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAcokRBeRaSFM1qXB+Qs+A74BkdNmfuxcN5PSKIsBfli apollo@mars"
        ];
      };

      users.users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAcokRBeRaSFM1qXB+Qs+A74BkdNmfuxcN5PSKIsBfli apollo@mars"
      ];

      security.sudo.wheelNeedsPassword = false;

      # ISO Image Configuration with Boot Options for Both Graphical and Text Mode
      image.fileName = lib.mkDefault "solar-installer-${config.system.nixos.release}-${pkgs.stdenv.hostPlatform.uname.processor}.iso";
      isoImage = {
        volumeID = lib.mkDefault "SOLAR_INSTALL";
        edition = lib.mkDefault "solar";
        configurationName = "Graphical Desktop (XFCE)";
        makeEfiBootable = true;
        makeUsbBootable = true;
        squashfsCompression = "zstd -Xcompression-level 6";
      };

      # Specialisation entry in boot menu for Console / Text Mode
      specialisation.textMode = {
        configuration = {
          isoImage.configurationName = lib.mkForce "Console / Text Mode";
          services.xserver.enable = lib.mkForce false;
          services.displayManager.autoLogin.enable = lib.mkForce false;
        };
      };

      # Bundle Solar repository and desktop launcher
      system.activationScripts.copySolarRepo = ''
        if [ ! -d /home/nixos/solar ]; then
          mkdir -p /home/nixos
          cp -r ${inputs.self.outPath} /home/nixos/solar
          chown -R nixos:users /home/nixos/solar
          chmod -R u+w /home/nixos/solar
        fi

        mkdir -p /home/nixos/Desktop
        cat << 'DESKTOP_EOF' > /home/nixos/Desktop/solar-install.desktop
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=Install Solar
        Comment=Install Solar on this computer
        Exec=xfce4-terminal -T "Solar Installer" --maximize -e "sudo solar-install"
        Icon=system-software-install
        Terminal=false
        StartupNotify=true
        Categories=System;
        DESKTOP_EOF
        chmod +x /home/nixos/Desktop/solar-install.desktop
        chown -R nixos:users /home/nixos/Desktop
      '';

      # Environment Packages & Tools
      environment.systemPackages = with pkgs; [
        solarInstallScript
        inputs.disko.packages.${pkgs.system}.disko
        inputs.agenix.packages.${pkgs.system}.default
        gparted
        firefox
        foot
        alacritty
        xfce4-terminal
        git
        curl
        wget
        rsync
        btop
        pciutils
        usbutils
        lshw
        dmidecode
        efibootmgr
        sbctl
        cryptsetup
        parted
        jq
        tree
        neovim
        mkpasswd
      ];

      # Informational MOTD for console / SSH logins
      environment.etc."motd".text = ''
        ☀️  =============================================================
            SOLAR LIVE SYSTEM INSTALLER
        =============================================================

        • Install Solar locally:   Run 'sudo solar-install'
        • Remote deployment:       Run 'install.sh' (nixos-anywhere)
        • Configure Wi-Fi:         Run 'nmtui'
        • Partition visually:      Run 'gparted' (Graphical Mode)
        • Remote SSH Access:       Authorized with key 'apollo@mars'
                                   (root / nixos, passwordless sudo)

        =============================================================
      '';
    };
}
