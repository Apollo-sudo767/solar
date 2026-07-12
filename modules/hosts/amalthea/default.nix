{
  meta = {
    system = "x86_64-linux";
    stable = false;
  };

  module =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        ./hardware-configuration.nix
      ];

      system.stateVersion = "26.11";

      # Amalthea: Handheld Gaming Device (Intel Atom z8350)
      myFeatures = {
        core = {
          system.core-branch.enable = true;
          system.users = {
            usernames = [ "hepheastus" ];
          };
          shell.shell-branch.enable = true;
          boot = {
            enable = true;
            loader = "limine"; # Limine is lighter and matches the project's aesthetic
            kernel = "zen"; # Zen kernel often has better responsiveness for gaming
          };
          security.security.enable = true;
          nix.lix.enable = true;
        };

        hardware = {
          cpu-gpu.intel.enable = true;
          peripherals.bluetooth.enable = true;
          peripherals.wifi.enable = true;
          input.controllers.enable = true;
        };

        platforms = {
          desktops.kde.enable = true;
          addons.displayManager.manager = "sddm";
        };

        programs = {
          media.steam = {
            enable = true;
            gamescope.enable = true;
          };
          terminal = {
            git.enable = true;
            ghostty.enable = true;
            helix.enable = true;
            fastfetch.enable = true;
            nh.enable = true;
            direnv.enable = true;
            nix-ld.enable = true;
          };
        };

        services = {
          multimedia.audio.enable = true;
          hardware.udisks2.enable = true;
          networking.enable = true;
        };
      };

      # Autologin for "Console-like" experience
      services.displayManager.autoLogin = {
        enable = true;
        user = config.myFeatures.core.system.users.mainUser;
      };

      services.displayManager.defaultSession = "steam";

      # Steam Autostart in Big Picture Mode
      home-manager.users.${config.myFeatures.core.system.users.mainUser} = {
        home.file.".config/autostart/steam.desktop".text = ''
          [Desktop Entry]
          Name=Steam (Big Picture)
          Exec=steam -tenfoot
          Terminal=false
          Type=Application
          Categories=Game;
          Actions=Gamescope;

          [Desktop Action Gamescope]
          Name=Launch in Gamescope
          Exec=steam-gamescope
        '';
      };

      # Specific Kernel Tweaks for Intel Atom z8350 Stability & Performance
      boot.kernelParams = [
        "intel_idle.max_cstate=1" # Prevents random freezes on some z8350 boards
        "intel_pstate=disable" # Use acpi_cpufreq for better control on low-end
      ];

      # Small Install: Disable documentation and extra bloat
      documentation.enable = false;
      documentation.nixos.enable = false;
      documentation.man.enable = false;
      documentation.info.enable = false;
      documentation.doc.enable = false;

      # NOTE: To hide the KDE taskbar, it's recommended to right-click the panel
      # and set "Visibility" to "Auto Hide" or "Hidden".
      # Doing this purely via Nix is brittle due to dynamic applet IDs.
    };
}
