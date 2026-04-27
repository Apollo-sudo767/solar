{
  meta = {
    system = "x86_64-linux";
    stable = false;
  };

  module = { lib, inputs, ... }: {
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
        cpu-gpu = {
          amd.enable = true;
          nvidia = {
            enable = true;
            open = false;
            beta = true;
          };
        };
        system.dualboot.enable = true;
        peripherals.bluetooth.enable = true;
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
          fastfetch.enable = true;
          helix.enable = true;
        };
        media = {
          gaming.enable = true;
          media.enable = true;
          obs.enable = true;
          davinci.enable = true;
        };
        browsers.firefox.enable = true;
        utilities = {
          stylePackages.enable = true;
          bitwarden.enable = true;
          anytype.enable = true;
          social.enable = true;
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
