# modules/hosts/europa/default.nix
# ==============================================================================
# Host Configuration — Europa (Intel + NVIDIA Optimus Gaming Laptop)
# ==============================================================================
# KDE Plasma 6 laptop workstation with legacy NVIDIA proprietary drivers +
# PRIME offload, systemd-boot, and Forest theme styling.
# ==============================================================================

{
  meta = {
    system = "x86_64-linux";
    stable = false;
    useSolarSecrets = false;
  };

  module =
    { ... }:
    {
      imports = [
        ./hardware-configuration.nix
      ];

      system.stateVersion = "26.11";

      myFeatures = {
        # 🌲 Dendritic Suites
        suites = {
          workstation.enable = true;
          gaming.enable = true;
          laptop.enable = true;
          desktops.plasma.enable = true;
        };

        # 🎛️ Host Specifics
        core = {
          system = {
            core-branch.enable = true;
            disko.enable = false;
            users.usernames = [ "hephaestus" ];
          };
          boot = {
            enable = true;
            loader = "systemd";
            kernel = "default";
          };
          security.security.useAppArmor = true;
        };

        hardware = {
          cpu-gpu = {
            nvidia = {
              enable = true;
              open = false;
              legacy = true;
              prime.enable = true;
            };
            intel.enable = true;
          };
          peripherals.battery.fullCharge = true;
        };

        platforms = {
          styling = {
            stylix.enable = true;
            themes.forest.enable = true;
          };
          addons.displayManager.manager = "sddm";
        };

        programs.media = {
          media.enable = true;
          vlc.enable = true;
        };

        services.networking.tailscale.enable = true;
      };
    };
}
