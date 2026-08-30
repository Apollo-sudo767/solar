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

      boot.initrd.systemd.enable = true;

      myFeatures = {
        # 🌲 Dendritic Suites
        suites = {
          workstation.enable = true;
          gaming.enable = true;
          laptop.enable = true;
          desktops.niri.enable = true;
        };

        # 🎛️ Host & Hardware Specifics
        core = {
          system = {
            core-branch = {
              enable = true;
              usePersistence = true;
            };
            users.agenixPassword = true;
            disko.speedDisks = [ "/dev/nvme0n1" ];
          };
          boot = {
            enable = true;
            secureBoot.enable = true;
            kernel = "latest";
          };
          security = {
            security.useAppArmor = true;
            agenix.enable = true;
          };
        };

        hardware = {
          cpu-gpu.intel.enable = true;
          system.ttyResolution = {
            enable = true;
            resolution = "1920x1080";
          };
          peripherals = {
            battery.fullCharge = true;
            wifi = {
              enable = true;
              persistence = true;
            };
          };
        };

        platforms = {
          desktops.niri.monitors = [
            {
              name = "eDP-1";
              resolution = "1080p";
              orientation = "horizontal";
            }
          ];
          styling = {
            stylix.enable = true;
            flavors.sky.enable = true;
          };
          addons.displayManager.manager = "regreet";
        };

        programs = {
          terminal.git = {
            userName = "Apollo-sudo767";
            userEmail = "fireshifter767@gmail.com";
          };
          browsers.firefox = {
            nightly.enable = true;
            extensions.enable = true;
          };
          media = {
            media.enable = true;
            obs.enable = true;
            vlc.enable = true;
          };
          office.ap-office.enable = true;
        };

        services = {
          hardware.firmware.enable = true;
          networking.tailscale.enable = true;
        };
      };
    };
}
