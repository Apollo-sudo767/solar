# flake.nix
{
  description = "Fully Automated Dendritic Flake";

  inputs = {
    # Core nixpkgs channels
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Flake Parts
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Home Manager
    home-manager-unstable.url = "github:nix-community/home-manager/master";
    home-manager-stable.url = "github:nix-community/home-manager/release-26.05";

    # Darwin
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Stylix
    stylix-unstable.url = "github:danth/stylix";
    stylix-stable.url = "github:danth/stylix/release-26.05";

    # Secrets Management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Your private repo (Only fetched when building your specific hosts)
    solar-secrets = {
      url = "git+ssh://git@github.com/Apollo-sudo767/solar-secrets.git";
      flake = false;
    };

    # Niri
    niri.url = "github:epireyn/niri-flake";

    # Paneru
    paneru = {
      url = "github:karinushka/paneru";
    };

    # Disko & Impermance
    disko.url = "github:nix-community/disko";
    impermanence.url = "github:nix-community/impermanence";
    preservation.url = "github:WilliButz/preservation";

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
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";

    # Firefox Nightly
    firefox.url = "github:nix-community/flake-firefox-nightly";

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
    treefmt-nix.url = "github:numtide/treefmt-nix";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
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
      { config, ... }:
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
        ];

        perSystem =
          {
            system,
            config,
            lib,
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
            };

            _module.args.pkgs = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true; # Required for things like sops or discord
            };
          };
      }
    );
}
