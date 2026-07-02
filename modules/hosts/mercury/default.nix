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

      boot.initrd.systemd.enable = true;

      myFeatures = {
        core = {
          system.core-branch = {
            enable = true;
            usePersistence = true;
          };
          system.users.agenixPassword = true;
          system.disko.speedDisks = [ "/dev/nvme0n1" ]; # Adjust if necessary
          shell.shell-branch.enable = true;
          boot = {
            enable = true;
            secureBoot.enable = true;
            kernel = "latest";
          };
          security.security = {
            enable = true;
            useAppArmor = true;
          };
          security.agenix.enable = true;
          nix.lix.enable = true;
        };

        hardware = {
          cpu-gpu.intel.enable = true;
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
              fullCharge = true;
              bluetooth.enable = true;
              aggressive = true;
            };
            bluetooth.enable = true;
            wifi = {
              enable = true;
              persistence = true;
            };
          };
          input = {
            controllers.enable = true;
            trackpad.enable = true;
          };
        };

        platforms = {
          styling = {
            stylix.enable = true;
            skyNiri.enable = true;
          };
          addons = {
            displayManager.manager = "regreet";
          };
        };

        programs = {
          terminal = {
            git = {
              enable = true;
              userName = "Apollo-sudo767";
              userEmail = "fireshifter767@gmail.com";
            };
            ghostty.enable = true;
            fastfetch = {
              enable = true;
            };
            helix.enable = true;
            antigravity.enable = true;
          };
          browsers.firefox = {
            enable = true;
            nightly.enable = true;
            extensions.enable = true;
          };
          media = {
            gaming.enable = true;
            media.enable = true;
            obs.enable = true;
            vlc.enable = true;
          };
          utilities = {
            bitwarden.enable = true;
            stylePackages.enable = true;
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
            syncthing.enable = true;
          };
        };
      };
    };
}
