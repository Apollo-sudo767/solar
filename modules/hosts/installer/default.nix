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
      solarInstallScript = pkgs.writeShellScriptBin "solar-install" (
        builtins.readFile ./solar-install.sh
      );

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

      # Enable modern Flakes and Nix CLI by default
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

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
        • Manual Disko install:    Run 'sudo disko --mode destroy,format,mount --flake .#<host>'
        • Configure Wi-Fi:         Run 'nmtui'
        • Partition visually:      Run 'gparted' (Graphical Mode)
        • Remote SSH Access:       Authorized with key 'apollo@mars'
                                   (root / nixos, passwordless sudo)

        =============================================================
      '';
    };
}
