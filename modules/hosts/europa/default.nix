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
          system = {
            core-branch.enable = true;
            users.usernames = [ "hephaestus" ];
          };
          nix.lix.enable = true;
          shell.shell-branch.enable = true;
        };
        platforms = {
          desktops.kde.enable = true;
          styling = {
            stylix.enable = true;
            themes.forest.enable = true;
          };
          addons.displayManager.manager = "sddm";
        };
        programs = {
          terminal = {
            ghostty.enable = true;
            fastfetch = {
              enable = true;
              showBattery = true;
            };
            helix.enable = true;
          };
          browsers.firefox.enable = true;
          media = {
            gaming.enable = true;
            media.enable = true;
            obs.enable = true;
          };
          utilities = {
            social.enable = true;
            bitwarden.enable = true;
            stylePackages.enable = true;
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
          };
          networking.tailscale.enable = true;
        };
        hardware = {
          system.graphics.enable = true;
          cpu-gpu = {
            nvidia = {
              enable = true;
              open = false;
              legacy = true;
              prime = {
                enable = true;
                intelBusId = "PCI:0:2:0";
                nvidiaBusId = "PCI:1:0:0";
              };
            };
            intel.enable = true;
          };
          peripherals = {
            battery = {
              enable = true;
              fullCharge = true;
              bluetooth.enable = false;
              aggressive = true;
            };
            wifi.enable = true;
          };
          input = {
            controllers.enable = true;
            trackpad.enable = true;
          };
        };
      };
    };
}
