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
        core = {
          system.core-branch = {
            enable = true;
            usePersistence = false;
          };
          system.disko = {
            enable = true;
            enableLuks = false;
          };
          system.users = {
            usernames = [ "daphne" ];
            agenixPassword = false;
          };
          shell.shell-branch.enable = true;
          boot = {
            enable = true;
            secureBoot.enable = false;
            kernel = "zen";
          };
          security.security = {
            enable = true;
            useAppArmor = true;
          };
          security.agenix.enable = false;
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
            wooting.enable = true;
          };
        };

        platforms = {
          desktops.kde.enable = true;
          styling = {
            stylix.enable = true;
            themes.forest.enable = true;
          };
          addons = {
            displayManager.manager = "sddm";
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
            nh.enable = true;
            direnv.enable = true;
            nix-ld.enable = true;
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
            ani-cli.enable = true;
          };
          browsers = {
            firefox = {
              nightly.enable = true;
              extensions.enable = true;
            };
          };
          utilities = {
            stylePackages.enable = true;
            bitwarden.enable = true;
            social.enable = true;
            vesktop.enable = false;
            filemanager.enable = true;
            spotify = {
              enable = false;
              tui.enable = true;
            };
          };
          office = {
            ap-office.enable = true;
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
          };
        };
      };
    };
}
