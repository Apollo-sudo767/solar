{
  meta = {
    system = "x86_64-linux";
    stable = false;
    useSolarSecrets = true;
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
            resolution = "2560x1440";
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
          peripherals = {
            bluetooth = {
              enable = true;
              gaming.enable = true;
            };
            wifi = {
              enable = true;
              persistence = true;
            };
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
          desktops.niri = {
            modKey = "super";
            defaultColumnWidth = 1.0;
            monitors = [
              {
                name = "ASUSTek COMPUTER INC VG27WQ3B TALMTR031961";
                aliases = [
                  "DP-2"
                  "DP-4"
                ];
                resolution = "1440p";
                refresh = 180.0;
                orientation = "horizontal";
                position = {
                  x = 1080;
                  y = 0;
                };
                vrr = true;
                primary = true;
                focusAtStartup = true;
              }
              {
                name = "ASUSTek COMPUTER INC VG278 LBLMQS200546";
                aliases = [
                  "DP-1"
                  "DP-5"
                ];
                resolution = "1080p";
                refresh = 165.0;
                orientation = "vertical";
                position = {
                  x = 0;
                  y = 0;
                };
                vrr = true;
              }
            ];
          };
          styling = {
            stylix.enable = true;
            flavors.sky.enable = true;
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
            tf2.enable = true;
            mumble.enable = true;
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
            webcord.enable = false;
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
          };
          networking = {
            enable = true;
            resolved.enable = true;
            tailscale.enable = true;
          };
        };
      };
    };
}
