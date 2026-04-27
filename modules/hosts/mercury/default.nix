{
  meta = {
    system = "x86_64-linux";
    stable = false;
  };

  module =
    { lib, inputs, ... }:
    {
      imports = [
        ./hardware-configuration.nix
      ];

      system.stateVersion = "26.05";

      myFeatures = {
        core = {
          enable = true;
          secureboot.enable = true;
          security = {
            enable = true;
            useAppArmor = true;
          };
          lix.enable = true;
        };
        shell.enable = true;

        hardware = {
          graphics.enable = true;
          battery = {
            enable = true;
            fullCharge = false;
            bluetooth.enable = true;
            aggressive = true;
          };
          bluetooth.enable = true;
          controllers.enable = true;
          trackpad.enable = true;
          wifi.enable = true;
        };

        systems = {
          presets.gruvboxNiri.enable = true;
          displayManager.manager = "tuigreet";
        };

        programs = {
          ghostty.enable = true;
          firefox.enable = true;
          gaming.enable = true;
          fastfetch = {
            enable = true;
            showBattery = true;
          };
          helix.enable = true;
          media.enable = true;
          social.enable = true;
          obs.enable = true;
          bitwarden.enable = true;
          stylePackages.enable = true;
          anytype.enable = true;
          gemini.enable = true;
        };

        services = {
          audio.enable = true;
          flatpak.enable = true;
          xdgPortals.enable = true;
          printing.enable = true;
          udisks2.enable = true;
          firmware.enable = true;
          networking = {
            tailscale.enable = true;
          };
        };
      };
    };
}
