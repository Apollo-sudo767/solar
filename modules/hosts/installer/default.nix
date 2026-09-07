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
                echo -e "\n''${RED}''${BOLD}❌ Installation failed at line $line_no (Exit code: $exit_code)''${NC}"
                echo -e "''${YELLOW}Review the errors above. The terminal will remain open for debugging.''${NC}"
                read -r -p "Press Enter to exit..." dummy || true
            fi
        }
        trap 'on_exit $? $LINENO' EXIT

        echo -e "''${CYAN}''${BOLD}"
        echo "  ☀️  ========================================================="
        echo "      SOLAR ON-DEVICE SYSTEM INSTALLER"
        echo "  ========================================================="
        echo -e "''${NC}"

        if [[ $EUID -ne 0 ]]; then
            echo -e "''${RED}❌ This installer must be run as root (or via sudo).''${NC}"
            echo "Please re-run with: sudo solar-install"
            exit 1
        fi

        # 1. Locate / Prepare Flake Repository
        echo -e "''${BOLD}📁 Solar Configuration Source:''${NC}"
        echo "  1) Pull latest from GitHub (Recommended - apollo-sudo767/solar) [Default]"
        echo "  2) Use bundled offline repository (/home/nixos/solar)"
        echo "  3) Use current directory ($PWD)"
        read -r -p "Select source [1-3] (default 1): " REPO_CHOICE
        REPO_CHOICE="''${REPO_CHOICE:-1}"

        FLAKE_DIR="/tmp/solar"
        case "$REPO_CHOICE" in
            2)
                if [[ -d "/home/nixos/solar" ]]; then
                    echo -e "''${BLUE}📁 Copying bundled repository to /tmp/solar...''${NC}"
                    rm -rf /tmp/solar
                    cp -r /home/nixos/solar /tmp/solar
                    chmod -R u+w /tmp/solar
                else
                    echo -e "''${YELLOW}Bundled repo not found, falling back to GitHub...''${NC}"
                    REPO_CHOICE="1"
                fi
                ;;
            3)
                if [[ -f "./flake.nix" ]]; then
                    echo -e "''${BLUE}📁 Using current directory ($PWD)...''${NC}"
                    FLAKE_DIR="$PWD"
                else
                    echo -e "''${YELLOW}No flake.nix in current directory, falling back to GitHub...''${NC}"
                    REPO_CHOICE="1"
                fi
                ;;
        esac

        if [[ "$REPO_CHOICE" == "1" ]]; then
            echo -e "''${BLUE}🌐 Fetching latest Solar repository from GitHub...''${NC}"
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

        # Ensure FLAKE_DIR is initialized as a git repository so Nix Flakes can evaluate it
        if [[ ! -d "$FLAKE_DIR/.git" ]]; then
            echo -e "''${BLUE}🔧 Initializing git repository in $FLAKE_DIR...''${NC}"
            git -C "$FLAKE_DIR" init >/dev/null 2>&1 || true
            git -C "$FLAKE_DIR" add -A >/dev/null 2>&1 || true
            git -C "$FLAKE_DIR" -c user.name="Solar" -c user.email="solar@localhost" commit -m "solar install staging" >/dev/null 2>&1 || true
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
            echo -e "''${RED}❌ No Linux hosts found in $FLAKE_DIR/modules/hosts/''${NC}"
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
            cp /tmp/hw-gen/hardware-configuration.nix "$HOST_DIR/hardware-configuration.nix"
            git -C "$FLAKE_DIR" add "$HOST_DIR/hardware-configuration.nix" >/dev/null 2>&1 || true
            echo -e "''${GREEN}✓ hardware-configuration.nix updated and staged for $SELECTED_HOST.''${NC}\n"
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
                OVERRIDE_SECRETS_ARG=(--override-input solar-secrets "path:$DUMMY_DIR")
            fi
        else
            DUMMY_DIR=$(mktemp -d)
            OVERRIDE_SECRETS_ARG=(--override-input solar-secrets "path:$DUMMY_DIR")
        fi

        # 7. Storage Preparation & Cleanup
        HAS_DISKO=true
        if grep -qE "disko\.enable\s*=\s*false" "$HOST_DIR/default.nix" 2>/dev/null; then
            HAS_DISKO=false
        fi

        # Clean up any active mounts, swap, and LUKS device-mapper locks
        echo -e "\n''${BLUE}🧹 Performing pre-flight storage cleanup (unmounting /mnt, disabling swap)...''${NC}"
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
            echo -e "\n''${RED}''${BOLD}⚠️  WARNING: Target drives configured in Disko for '$SELECTED_HOST' will be COMPLETELY WIPED!''${NC}"
            echo -e "All existing partitions and data on target disk(s) will be destroyed."
            read -r -p "Type 'yes' to proceed with Disko partitioning and installation: " CONFIRM
            if [[ "$CONFIRM" != "yes" ]]; then
                echo "Installation aborted by user."
                exit 0
            fi

            # Stage all changes in git so Disko and Nix Flakes see them
            git -C "$FLAKE_DIR" add -A 2>/dev/null || true

            # 8. Run Disko
            echo -e "\n''${CYAN}🚀 Phase 1/3: Partitioning and mounting storage via Disko...''${NC}"
            disko --mode disko --yes-wipe-all-disks --flake "$FLAKE_DIR#$SELECTED_HOST" "''${OVERRIDE_SECRETS_ARG[@]}"

            # Verify that Disko mounted the root filesystem to /mnt
            if ! findmnt /mnt >/dev/null 2>&1; then
                echo -e "''${RED}❌ Disko failed to mount target filesystem to /mnt. Aborting.''${NC}"
                exit 1
            fi
            echo -e "''${GREEN}✓ Storage partitioned and mounted at /mnt successfully.''${NC}"
        else
            echo -e "\n''${YELLOW}ℹ️  Notice: Disko is disabled for '$SELECTED_HOST'.''${NC}"
            if ! findmnt /mnt >/dev/null 2>&1; then
                echo -e "''${RED}❌ No filesystem mounted at /mnt. Please mount target storage to /mnt first.''${NC}"
                exit 1
            fi
            echo -e "\n''${CYAN}🚀 Phase 1/3: Storage verified at /mnt (manual layout). Skipping Disko...''${NC}"
        fi

        # Stage Initial User Password before activation
        echo -e "\n''${CYAN}🔑 Staging credentials before NixOS install...''${NC}"
        mkdir -p /mnt/etc
        if [ -n "$PASSWORD_HASH" ]; then
            echo "$PASSWORD_HASH" > /mnt/etc/user-password
            chmod 600 /mnt/etc/user-password
        fi

        if [[ -d "/mnt/persist" ]] && [ -n "$PASSWORD_HASH" ]; then
            mkdir -p /mnt/persist/etc
            echo "$PASSWORD_HASH" > /mnt/persist/etc/user-password
            chmod 600 /mnt/persist/etc/user-password
            echo -e "''${GREEN}✓ Mirrored user password to /persist/etc/user-password''${NC}"
        fi

        # 9. Run NixOS Install
        echo -e "\n''${CYAN}🚀 Phase 2/3: Installing NixOS system ($SELECTED_HOST)...''${NC}"
        git -C "$FLAKE_DIR" add -A 2>/dev/null || true
        nixos-install --flake "$FLAKE_DIR#$SELECTED_HOST" "''${OVERRIDE_SECRETS_ARG[@]}" --no-root-password

        # 10. Finalize User Credentials
        echo -e "\n''${CYAN}🚀 Phase 3/3: Finalizing system configuration...''${NC}"
        PRIMARY_USER=$(grep -oE 'usernames\s*=\s*\[\s*"[^"]+"' "$HOST_DIR/default.nix" 2>/dev/null | head -n1 | sed -E 's/.*"([^"]+)".*/\1/' || echo "apollo")
        PRIMARY_USER="''${PRIMARY_USER:-apollo}"
        if [ -n "$PASSWORD_HASH" ]; then
            nixos-enter --root /mnt -c "echo '$PRIMARY_USER:$PASSWORD_HASH' | chpasswd -e" 2>/dev/null || true
            echo -e "''${GREEN}✓ Account '$PRIMARY_USER' password initialized in /etc/shadow''${NC}"
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

      solarInstallLauncher = pkgs.writeShellScriptBin "solar-install-gui" ''
        #!/usr/bin/env bash
        if command -v xfce4-terminal >/dev/null 2>&1; then
          exec xfce4-terminal --title="Solar Installer" --maximize --execute sudo solar-install
        elif command -v konsole >/dev/null 2>&1; then
          exec konsole --title "Solar Installer" -e sudo solar-install
        elif command -v gnome-terminal >/dev/null 2>&1; then
          exec gnome-terminal --title="Solar Installer" --maximize -- sudo solar-install
        elif command -v foot >/dev/null 2>&1; then
          exec foot --title="Solar Installer" sudo solar-install
        elif command -v alacritty >/dev/null 2>&1; then
          exec alacritty --title "Solar Installer" -e sudo solar-install
        elif command -v x-terminal-emulator >/dev/null 2>&1; then
          exec x-terminal-emulator -T "Solar Installer" -e sudo solar-install
        else
          exec sudo solar-install
        fi
      '';

      desktopLauncher = pkgs.makeDesktopItem {
        name = "solar-install";
        desktopName = "Install Solar";
        comment = "Install Solar on this computer";
        exec = "solar-install-gui";
        icon = "system-software-install";
        terminal = false;
        categories = [
          "System"
        ];
      };
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

      # Graphical Desktops: XFCE, GNOME, and KDE Plasma 6
      services.xserver = {
        enable = true;
        desktopManager.xfce.enable = true;
      };
      services.desktopManager.gnome.enable = true;
      services.desktopManager.plasma6.enable = true;

      # Resolve conflict between GNOME seahorse and KDE ksshaskpass
      programs.ssh.askPassword = lib.mkForce "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";

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
        configurationName = "Graphical Desktop (XFCE - Universal Safe Mode)";
        makeEfiBootable = true;
        makeUsbBootable = true;
        squashfsCompression = "zstd -Xcompression-level 6";
      };

      # Specialisation entries in ISO boot menu
      specialisation = {
        plasma = {
          configuration = {
            isoImage.configurationName = lib.mkForce "KDE Plasma 6 Desktop";
            services.displayManager.defaultSession = lib.mkForce "plasma";
          };
        };
        gnome = {
          configuration = {
            isoImage.configurationName = lib.mkForce "GNOME Desktop";
            services.displayManager.defaultSession = lib.mkForce "gnome";
          };
        };
        textMode = {
          configuration = {
            isoImage.configurationName = lib.mkForce "Console / Text Mode";
            services.xserver.enable = lib.mkForce false;
            services.desktopManager.gnome.enable = lib.mkForce false;
            services.desktopManager.plasma6.enable = lib.mkForce false;
            services.displayManager.autoLogin.enable = lib.mkForce false;
          };
        };
      };

      # Bundle Solar repository and desktop launcher applet
      system.activationScripts.copySolarRepo = ''
                if [ ! -d /home/nixos/solar ]; then
                  mkdir -p /home/nixos
                  cp -r ${inputs.self.outPath} /home/nixos/solar
                  chown -R nixos:users /home/nixos/solar
                  chmod -R u+w /home/nixos/solar

                  # Initialize as a valid Git repository so Nix Flakes can evaluate it offline
                  ${pkgs.git}/bin/git -C /home/nixos/solar init >/dev/null 2>&1 || true
                  ${pkgs.git}/bin/git -C /home/nixos/solar add -A >/dev/null 2>&1 || true
                  ${pkgs.git}/bin/git -C /home/nixos/solar -c user.name="Solar" -c user.email="solar@localhost" commit -m "solar iso bundle" >/dev/null 2>&1 || true
                fi

                mkdir -p /home/nixos/Desktop
                cp ${desktopLauncher}/share/applications/solar-install.desktop /home/nixos/Desktop/solar-install.desktop
                chmod +x /home/nixos/Desktop/solar-install.desktop
                chown -R nixos:users /home/nixos/Desktop
      '';

      # Environment Packages & Tools
      environment.systemPackages = with pkgs; [
        solarInstallScript
        solarInstallLauncher
        desktopLauncher
        inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko
        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
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
