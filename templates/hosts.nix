# templates/hosts.nix
# ============================================================================
# Host Leaf Template (`modules/hosts/<hostname>/default.nix`)
# ============================================================================
# Copy this file to `modules/hosts/<hostname>/default.nix` (or run
# `nix run .#bootstrap-host <hostname>`) to add a new machine to the fleet.
# `modules/hosts/default.nix` automatically discovers every folder in
# `modules/hosts/`—no manual registration in `flake.nix` is required.
{
  # 1. PEEKABLE METADATA
  # Read during flake discovery before evaluating the full NixOS/Darwin module tree.
  meta = {
    system = "x86_64-linux"; # Target architecture: "x86_64-linux", "aarch64-linux", or "aarch64-darwin"
    stable = false; # false = nixpkgs-unstable (rolling), true = nixpkgs-stable (release)
    useSolarSecrets = false; # Set to false for standalone builds without private solar-secrets access
  };

  # 2. SYSTEM MODULE
  # Evaluated by `nixosSystem` (Linux) or `darwinSystem` (macOS).
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
          desktops.niri.enable = true;
        };

        # 🎛️ Core Foundation
        core = {
          system = {
            core-branch = {
              enable = true;
              usePersistence = true; # Ephemeral tmpfs root with `/persist` state preservation
            };
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
            security = {
              enable = true;
              useAppArmor = true;
            };
            ssh.enable = true;
            agenix.enable = false; # Set to true once host SSH keys are registered in solar-secrets
          };
        };

        # 🖥️ Platforms, Compositors & Styling (Strictly decided per host leaf!)
        platforms = {
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
