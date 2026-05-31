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

      system.stateVersion = "26.11";

      myFeatures = {
        core = {
          system = {
            core-branch.enable = true;
          };
          shell.shell-branch.enable = true;
          boot = {
            enable = true;
            secureBoot.enable = true;
            kernel = "zen";
          };
          security.security = {
            enable = true;
            useAppArmor = true;
          };
          nix.lix.enable = true;
        };
        hardware = {
          cpu-gpu = {
            amd.enable = true;
            nvidia = {
              enable = true;
              open = true;
              beta = true;
            };
          };
          system = {
            dualboot.enable = true;
            ttyResolution = {
              enable = true;
              resolution = "2560x1440";
            };
          };
          peripherals.bluetooth.enable = true;
          input = {
            controllers = {
              enable = true;
              xbox = true;
            };
          };
        };
        platforms = {
          styling = {
            stylix.enable = true;
            spaceNiri.enable = true;
          };
          addons = {
            displayManager.manager = "regreet";
          };
        };
        programs = {
          terminal = {
            ghostty.enable = true;
            fastfetch.enable = true;
            helix.enable = true;
            gemini.enable = true;
          };
          media = {
            gaming.enable = true;
            media.enable = true;
            obs.enable = true;
            davinci.enable = true;
          };
          browsers.firefox = {
            enable = true;
            nightly.enable = true;
            extensions.enable = true;
          };
          utilities = {
            stylePackages.enable = true;
            bitwarden.enable = true;
            anytype.enable = true;
            social.enable = true;
            silverbullet.enable = true;
          };
        };
        services = {
          multimedia = {
            audio.enable = true;
            sunshine = {
              enable = true;
              port = 48000;
            };
          };
          system = {
            flatpak.enable = true;
            xdgPortals.enable = true;
          };
          hardware = {
            printing.enable = true;
            udisks2.enable = true;
          };
          networking = {
            enable = true;
            tailscale.enable = true;
          };
        };
      };
    };
}
