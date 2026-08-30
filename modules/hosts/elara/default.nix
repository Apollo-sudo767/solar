{
  meta = {
    system = "x86_64-linux";
    stable = true;
    useSolarSecrets = false;
  };

  module =
    { ... }:
    {
      imports = [
        ./hardware-configuration.nix
      ];

      system.stateVersion = "26.05";

      myFeatures = {
        # 🌲 Dendritic Suites
        suites = {
          workstation.enable = true;
          gaming.enable = true;
          desktops.plasma.enable = true;
        };

        # 🎛️ Host Specifics
        core = {
          system = {
            core-branch = {
              enable = true;
              usePersistence = false;
            };
            disko = {
              enable = true;
              enableLuks = false;
            };
            users = {
              usernames = [ "daphne" ];
              agenixPassword = false;
            };
          };
          boot = {
            enable = true;
            secureBoot.enable = false;
            kernel = "zen";
          };
          security = {
            security.useAppArmor = true;
            agenix.enable = false;
          };
        };

        hardware.cpu-gpu = {
          amd.enable = true;
          nvidia = {
            enable = true;
            open = true;
          };
        };

        platforms = {
          styling = {
            stylix.enable = true;
            themes.strawberry.enable = true;
          };
          addons.displayManager.manager = "sddm";
        };

        programs = {
          media = {
            steam.protonInstaller.enable = true;
            media.enable = true;
            obs.enable = true;
            davinci.enable = true;
            vlc.enable = true;
            ani-cli.enable = true;
          };
          browsers.firefox = {
            nightly.enable = true;
            extensions.enable = true;
          };
          utilities.spotify.tui.enable = true;
          office.ap-office.enable = true;
        };

        services = {
          multimedia.sunshine = {
            enable = true;
            port = 48000;
          };
          hardware.openrgb.enable = true;
          networking.tailscale.enable = true;
        };
      };
    };
}
