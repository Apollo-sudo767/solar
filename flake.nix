# ============================================================================
# Solar — Fully Automated Dendritic NixOS & nix-darwin Meta-Distribution
# ============================================================================
#
# Architecture Overview:
# Solar uses the "Dendritic" pattern combined with `flake-parts`:
# 1. `parts/` contains modular Flake outputs (host discovery, devShells,
#    treefmt code formatting, and pre-commit hooks).
# 2. `modules/default.nix` recursively scans `modules/` and automatically
#    imports every `.nix` feature module—no manual import lists required.
# 3. `modules/hosts/default.nix` discovers every directory under `modules/hosts/`
#    and builds either a NixOS (`nixosSystem`) or macOS (`darwinSystem`)
#    configuration based on the host's `meta.system` attribute.
#
# Antigravity Rule: All code changes made by Antigravity MUST be created on a feature
# branch and submitted as a GitHub Pull Request (PR) for review. Direct pushes to main are prohibited.
{
  description = "Fully Automated Dendritic Flake";

  # ==========================================================================
  # 1. FLAKE INPUTS (External Dependencies & Channels)
  # ==========================================================================
  inputs = {
    # Core Nixpkgs channels:
    # Individual hosts choose between unstable (rolling) and stable (release)
    # via `meta.stable = true/false;` in their `modules/hosts/<name>/default.nix`.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Flake Parts: Modularizes flake outputs into `parts/*.nix`
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Home Manager: Manages user dotfiles and user-level packages inline
    # within system configurations (matched to the host's nixpkgs channel).
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # nix-darwin: Declarative macOS system management (used when `meta.system` ends in `-darwin`)
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Stylix: Automated system-wide base16 color schemes, fonts, and wallpapers
    stylix-unstable = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    stylix-stable = {
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Secrets Management:
    # - `agenix` decrypts secrets at boot using the host's SSH Ed25519 key.
    # - `agenix-rekey` allows encrypting secrets once with a hardware master key
    #   (YubiKey / Secure Enclave) and automatically rekeying them for each target host.
    # - `solar-secrets` holds the private master-encrypted `.age` files and host pubkeys.
    #   Forkers without access to `solar-secrets` can set `meta.useSolarSecrets = false;`
    #   in their host configuration to build completely standalone systems.
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    solar-secrets = {
      url = "git+https://github.com/Apollo-sudo767/solar-secrets.git";
      flake = false;
    };

    # Declarative Disk Partitioning & Ephemeral Root State Preservation:
    # - `disko` formats drives (GPT, ESP, LUKS2, Btrfs subvolumes, ZFS pools).
    # - `preservation` bind-mounts essential state from `/persist` when running
    #   with an ephemeral tmpfs root (`usePersistence = true`).
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    preservation = {
      url = "github:WilliButz/preservation";
    };

    # Desktop & Application Flakes
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Bedrock On Linux (Minecraft Bedrock for Windows via Proton/GDK)
    bedrock-on-linux = {
      url = "github:Wyze3306/BedrockOnLinux";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Declarative Flatpak Management
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # Firefox Nightly
    firefox = {
      url = "github:nix-community/flake-firefox-nightly";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Noctalia v5 Wayland Desktop Shell (Quickshell-based bar, launcher, notifications, lockscreen)
    noctalia-v5 = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Ironbar Wayland Status Bar
    ironbar = {
      url = "github:JakeStanger/ironbar";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Code Formatting & Git Pre-Commit Hooks
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Self-hosted Joplin Server Flake
    joplin-server = {
      url = "github:Apollo-sudo767/joplin-server";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  # ==========================================================================
  # 2. FLAKE OUTPUTS (Evaluated via Flake Parts)
  # ==========================================================================
  outputs =
    inputs@{
      self,
      nixpkgs-unstable,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        # Import `./parts` (which auto-discovers all files in `parts/`) and
        # the canonical `agenix-rekey` flake module so `perSystem.agenix-rekey`
        # is available across all supported architectures.
        imports = [
          ./parts
          inputs.agenix-rekey.flakeModule
        ];

        # Supported build & target architectures across Linux and macOS (Apple Silicon / Intel)
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
          "x86_64-darwin"
        ];

        perSystem =
          {
            system,
            lib,
            pkgs,
            ...
          }:
          {
            # Configure agenix-rekey to scan our discovered hosts when rekeying secrets.
            # We only include darwinConfigurations when running on macOS to avoid
            # Secure Enclave / platform identity mismatches on Linux.
            agenix-rekey = {
              nixosConfigurations = self.nixosConfigurations or { };
              darwinConfigurations =
                if lib.hasSuffix "-darwin" system then (self.darwinConfigurations or { }) else { };
            };

            # Helper CLI apps runnable via `nix run .#<app>`
            apps = {
              # Secret management helpers (`s-gen`, `s-rekey`, `s-edit`, `s-sync` shell aliases wrap these)
              agenix-rekey-generate = {
                type = "app";
                program = lib.getExe self.agenix-rekey.${system}.generate;
              };
              agenix-rekey-rekey = {
                type = "app";
                program = lib.getExe self.agenix-rekey.${system}.rekey;
              };
              agenix-rekey-edit = {
                type = "app";
                program = lib.getExe self.agenix-rekey.${system}.edit-view;
              };
              agenix-rekey-update-masterkeys = {
                type = "app";
                program = lib.getExe self.agenix-rekey.${system}.update-masterkeys;
              };

              # Unified system rebuild command (`nix run .#rebuild`):
              # Automatically dispatches to `darwin-rebuild` on macOS or `nh os switch` on NixOS.
              rebuild = {
                type = "app";
                program = lib.getExe (
                  pkgs.writeShellScriptBin "rebuild" ''
                    if [ "$(uname)" = "Darwin" ]; then
                      exec darwin-rebuild switch --flake . "$@"
                    else
                      exec ${lib.getExe pkgs.nh} os switch . "$@"
                    fi
                  ''
                );
              };

              # Host scaffolding generator (`nix run .#bootstrap-host <hostname>`):
              # Creates a ready-to-build host directory under `modules/hosts/<hostname>/`
              # following the `{ meta = ...; module = ...; }` schema expected by `modules/hosts/default.nix`.
              bootstrap-host = {
                type = "app";
                program = lib.getExe (
                  pkgs.writeShellScriptBin "bootstrap-host" ''
                    set -euo pipefail
                    HOST="''${1:-}"
                    if [ -z "$HOST" ]; then
                      echo "Usage: nix run .#bootstrap-host <hostname>"
                      exit 1
                    fi
                    HOST_DIR="modules/hosts/$HOST"
                    if [ -d "$HOST_DIR" ]; then
                      echo "Host '$HOST' already exists in $HOST_DIR."
                    else
                      mkdir -p "$HOST_DIR"
                      cat <<'EOF' > "$HOST_DIR/default.nix"
                    {
                      meta = {
                        system = "x86_64-linux";
                        stable = false;
                        useSolarSecrets = false;
                      };

                      module =
                        { config, lib, pkgs, ... }:
                        {
                          imports = [ ./hardware-configuration.nix ];

                          system.stateVersion = "26.11";

                          myFeatures = {
                            core = {
                              system = {
                                core-branch.enable = true;
                                users.usernames = [ "apollo" ];
                              };
                              boot.enable = true;
                            };
                          };
                        };
                    }
                    EOF
                      cat <<'EOF' > "$HOST_DIR/hardware-configuration.nix"
                    # Placeholder hardware-configuration.nix — replace with output of `nixos-generate-config`
                    _: { }
                    EOF
                      echo "Created $HOST_DIR template."
                    fi
                  ''
                );
              };
            };

            # Provide a default `pkgs` instance for `perSystem` modules (devShells, treefmt, etc.)
            _module.args.pkgs = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
      }
    );
}
