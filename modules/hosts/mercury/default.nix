{
  meta = {
    system = "x86_64-linux";
    stable = false;
  };

  module =
    { ... }:
    {
      imports = [
        ./hardware-configuration.nix
      ];

      system.stateVersion = "26.05";

      myFeatures = {
        core = {
          system.core-branch.enable = true;
          shell.shell-branch.enable = true;
          boot.secureboot.enable = true;
          security.security = {
            enable = true;
            useAppArmor = true;
          };
          nix.lix.enable = true;
        };

        hardware = {
          system = {
            graphics.enable = true;
            ttyResolution = {
              enable = true;
              resolution = "1920x1080";
            };
          };
          peripherals = {
            battery = {
              enable = true;
              fullCharge = false;
              bluetooth.enable = true;
              aggressive = true;
            };
            bluetooth.enable = true;
            wifi.enable = true;
          };
          input = {
            controllers.enable = true;
            trackpad.enable = true;
          };
        };

        platforms = {
          styling = {
            stylix.enable = true;
            gruvboxNiri.enable = true;
          };
          addons.displayManager.manager = "tuigreet";
        };

        programs = {
          terminal = {
            ghostty.enable = true;
            fastfetch = {
              enable = true;
              showBattery = true;
            };
            helix.enable = true;
            gemini.enable = true;
          };
          browsers.firefox.enable = true;
          media = {
            gaming.enable = true;
            media.enable = true;
            obs.enable = true;
          };
          utilities = {
            bitwarden.enable = true;
            stylePackages.enable = true;
            anytype.enable = true;
            social.enable = true;
          };
        };

        services = {
          multimedia.audio.enable = true;
          system = {
            flatpak.enable = true;
            xdgPortals.enable = true;
          };
          hardware = {
            printing.enable = true;
            udisks2.enable = true;
            firmware.enable = true;
          };
          networking = {
            tailscale.enable = true;
          };
        };
      };
    };
}
