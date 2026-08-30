{
  meta = {
    system = "x86_64-linux";
    stable = false;
  };

  module =
    {
      config,
      ...
    }:
    {
      imports = [
        ./hardware-configuration.nix
      ];

      system.stateVersion = "26.11";

      # Amalthea: Handheld Gaming Device (Intel Atom z8350)
      myFeatures = {
        # 🌲 Dendritic Suites
        suites = {
          gaming.enable = true;
          desktops.plasma.enable = true;
        };

        # 🎛️ Host Specifics
        core = {
          system = {
            core-branch.enable = true;
            disko = {
              enable = true;
              enableLuks = false;
            };
            users.usernames = [ "hepheastus" ];
          };
          shell.shell-branch.enable = true;
          boot = {
            enable = true;
            loader = "limine";
            kernel = "zen";
          };
          security.security.enable = true;
        };

        hardware = {
          cpu-gpu.intel.enable = true;
          peripherals = {
            bluetooth.enable = true;
            wifi = {
              enable = true;
              persistence = true;
            };
          };
        };

        programs = {
          terminal = {
            git.enable = true;
            ghostty.enable = true;
            helix.enable = true;
            fastfetch.enable = true;
            nh.enable = true;
            direnv.enable = true;
            nix-ld.enable = true;
          };
          media.steam.gamescope.enable = true;
        };

        platforms.addons.displayManager.manager = "sddm";

        services.networking.enable = true;
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
    };
}
