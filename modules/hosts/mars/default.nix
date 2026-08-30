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
        # 🌲 1. Composite Domain Suites
        suites = {
          workstation.enable = true;
          gaming.enable = true;
          creator.enable = true;
          streaming.enable = true;
          productivity.enable = true;
          hardened.enable = true;
          networking.enable = true;
          desktops.niri.enable = true;
        };

        # 🎛️ 2. Core Storage, Bootloader & Secrets
        core = {
          system = {
            core-branch = {
              enable = true;
              usePersistence = true;
            };
            users.agenixPassword = true;
            disko = {
              speedDisks = [
                "/dev/nvme1n1"
                "/dev/nvme0n1"
              ];
              bulkDisks = [
                "/dev/sdb"
                "/dev/sda"
              ];
            };
          };
          boot = {
            enable = true;
            secureBoot.enable = true;
            kernel = "zen";
            resolution = "2560x1440";
          };
          security.agenix.usePrivateSecrets = true;
        };

        # ⚙️ 3. Hardware Drivers & Peripherals
        hardware = {
          cpu-gpu = {
            amd.enable = true;
            nvidia = {
              enable = true;
              open = true;
            };
          };
          system.ttyResolution = {
            enable = true;
            resolution = "2560x1440";
          };
          peripherals = {
            bluetooth.gaming.enable = true;
            wifi = {
              enable = true;
              persistence = true;
            };
          };
          input.wooting.enable = true;
        };

        # 🖥️ 4. Output Topology, Host Styling & Display Manager
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
          addons.displayManager.manager = "regreet";
        };

        # 👤 5. Host Credentials & Nightly Browser
        programs = {
          terminal.git = {
            userName = "Apollo-sudo767";
            userEmail = "fireshifter767@gmail.com";
          };
          browsers.firefox = {
            nightly.enable = true;
            extensions.enable = true;
          };
          utilities.spotify.tui.enable = true;
        };
      };
    };
}
