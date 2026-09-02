# flake.nix
# Solar - Fully Automated Dendritic Flake
#
# Antigravity Rule: All code changes made by Antigravity MUST be created on a feature
# branch and submitted as a GitHub Pull Request (PR) for review. Direct pushes to main are prohibited.
{
  description = "Fully Automated Dendritic Flake";

  inputs = {
    # Core nixpkgs channels
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Flake Parts
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Home Manager
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Darwin
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Stylix
    stylix-unstable = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    stylix-stable = {
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Secrets Management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    solar-secrets = {
      url = "git+ssh://git@github.com/Apollo-sudo767/solar-secrets.git";
      flake = false;
    };

    # Disko & Impermanence
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    preservation = {
      url = "github:WilliButz/preservation";
    };

    # Zen Browser
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Spicetify
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Nix Minecraft
    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Declarative Flatpak Management
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # Firefox Nightly
    firefox = {
      url = "github:nix-community/flake-firefox-nightly";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Noctalia
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    noctalia-v5 = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Iron Bar
    ironbar = {
      url = "github:JakeStanger/ironbar";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Formatting & Linting
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Joplin Server Flake
    joplin-server = {
      url = "github:Apollo-sudo767/joplin-server";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

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
        imports = [
          ./parts
          inputs.agenix-rekey.flakeModule
        ];

        # Add MacBook (Darwin) support alongside Linux
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
            agenix-rekey = {
              # Tells agenix-rekey which nodes to scan for secrets
              # We only include the relevant host types based on current platform
              # to avoid identity mismatches with master keys.
              nixosConfigurations = self.nixosConfigurations or { };
              darwinConfigurations =
                if lib.hasSuffix "-darwin" system then (self.darwinConfigurations or { }) else { };
            };

            # Define apps for convenience
            apps = {
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
              docs = {
                type = "app";
                program = lib.getExe (
                  pkgs.writeShellScriptBin "docs" ''
                    ${lib.getExe pkgs.mdbook} serve --open "$@"
                  ''
                );
              };
              rebuild = {
                type = "app";
                program = lib.getExe (
                  pkgs.writeShellScriptBin "rebuild" ''
                    if [ "$(uname)" = "Darwin" ]; then
                      exec ${lib.getExe pkgs.nix-darwin or "darwin-rebuild"} switch --flake . "$@"
                    else
                      exec ${lib.getExe pkgs.nh} os switch . "$@"
                    fi
                  ''
                );
              };
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
                                          cat <<EOF > "$HOST_DIR/default.nix"
                    { config, lib, pkgs, ... }:

                    {
                      meta = {
                        system = "x86_64-linux";
                        stable = false;
                      };

                      module = {
                        imports = [ ./hardware-configuration.nix ];

                        myFeatures = {
                          core = {
                            system.core-branch.enable = true;
                            system.users.mainUser = "apollo";
                          };
                        };
                      };
                    }
                    EOF
                                          touch "$HOST_DIR/hardware-configuration.nix"
                                          echo "Created $HOST_DIR template."
                                        fi
                  ''
                );
              };
            };

            _module.args.pkgs = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true; # Required for things like sops or discord
            };
          };
      }
    );
}
