# templates/hosts.nix
# Template for creating a new machine leaf under modules/hosts/<hostname>/default.nix
{
  # 1. PEEKABLE METADATA (Read during flake discovery without evaluating the whole module)
  meta = {
    system = "x86_64-linux"; # or "aarch64-darwin", "aarch64-linux"
    stable = false; # false tracks nixpkgs-unstable, true tracks nixpkgs-stable
    useSolarSecrets = true; # false allows completely self-contained builds without private secrets
  };

  # 2. SYSTEM MODULE
  module =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        ./hardware-configuration.nix
      ];

      system.stateVersion = "26.11";

      myFeatures = {
        # 🌲 High-Level Composite Suites (Workflows)
        suites = {
          workstation.enable = true;
          gaming.enable = true;
          development.enable = true;
        };

        # 🎛️ Core Foundation
        core = {
          system = {
            core-branch.enable = true;
            usePersistence = true; # Ephemeral tmpfs root with preservation
            users.usernames = [ "apollo" ];
            disko = {
              enable = true;
              enableLuks = true;
              speedDisks = [ "/dev/nvme0n1" ];
            };
          };
          boot = {
            enable = true;
            loader = "limine";
            kernel = "latest";
          };
          security = {
            security.enable = true;
            useAppArmor = true;
            ssh.enable = true;
            agenix.enable = true;
          };
        };

        # 🖥️ Platforms, Compositors & Styling (Strictly decided per host!)
        platforms = {
          desktops.niri.enable = true;
          addons.displayManager.manager = "regreet";
          styling = {
            stylix.enable = true;
            flavors.sky.enable = true;
          };
        };

        # ⚡ Hardware Specifics
        hardware.cpu-gpu.amd.enable = true;
      };
    };
}
