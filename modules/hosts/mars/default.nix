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
          system.core-branch = {
            enable = true;
            usePersistence = true;
          };
          system.users.agenixPassword = true;
          system.disko = {
            speedDisks = [
              "/dev/nvme1n1"
              "/dev/nvme0n1"
            ];
            bulkDisks = [
              "/dev/sdb"
              "/dev/sda"
            ];
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
          security.agenix = {
            enable = true;
            usePrivateSecrets = true;
          };
          nix.lix.enable = true;
        };

        hardware = {
          cpu-gpu = {
            amd.enable = true;
            nvidia = {
              enable = true;
              open = true;
            };
          };
          system = {
            ttyResolution = {
              enable = true;
              resolution = "2560x1440";
            };
          };
          peripherals.bluetooth = {
            enable = true;
            gaming.enable = true;
          };
          input = {
            controllers = {
              enable = true;
              xbox = true;
              nintendo = true;
            };
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
            fastfetch.enable = true;
            helix.enable = true;
            antigravity.enable = true;
          };
          media = {
            gaming.enable = true;
            steam = {
              protonInstaller.enable = true;
              gamescope = {
                enable = true;
                autoWrap = false;
              };
            };
            media.enable = true;
            obs.enable = true;
            davinci.enable = true;
            vlc.enable = true;
          };
          browsers = {
            firefox = {
              enable = true;
              nightly.enable = true;
              extensions.enable = true;
            };
            chrome = {
              enable = true;
              ungoogled.enable = true;
            };
          };
          utilities = {
            stylePackages.enable = true;
            bitwarden.enable = true;
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
            openrgb.enable = true;
          };
          networking = {
            enable = true;
            tailscale.enable = true;
            syncthing.enable = true;
          };
        };
      };
    };
}
