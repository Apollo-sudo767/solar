# flake.nix
{
  description = "Fully Automated Dendritic Flake";

  inputs = {
    # Core nixpkgs channels
    nixpkgs-unstable.url = "git+ssh://git@github.com/NixOS/nixpkgs.git?ref=nixos-unstable";
    nixpkgs-stable.url = "git+ssh://git@github.com/NixOS/nixpkgs.git?ref=nixos-26.05";

    # Flake Parts
    flake-parts.url = "git+ssh://git@github.com/hercules-ci/flake-parts.git";

    # Home Manager
    home-manager-unstable.url = "git+ssh://git@github.com/nix-community/home-manager.git?ref=master";
    home-manager-stable.url = "git+ssh://git@github.com/nix-community/home-manager.git?ref=release-26.05";

    # Darwin
    nix-darwin = {
      url = "git+ssh://git@github.com/nix-darwin/nix-darwin.git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Stylix
    stylix-unstable.url = "git+ssh://git@github.com/danth/stylix.git";
    stylix-stable.url = "git+ssh://git@github.com/danth/stylix.git?ref=release-26.05";

    # Secrets Management
    agenix = {
      url = "git+ssh://git@github.com/ryantm/agenix.git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    agenix-rekey = {
      url = "git+ssh://git@github.com/oddlama/agenix-rekey.git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    solar-secrets = {
      url = "git+ssh://git@github.com/Apollo-sudo767/solar-secrets.git";
      flake = false;
    };

    # Niri
    niri = {
      url = "git+ssh://git@github.com/epireyn/niri-flake.git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Paneru
    paneru = {
      url = "git+ssh://git@github.com/karinushka/paneru.git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Disko & Impermanence
    disko = {
      url = "git+ssh://git@github.com/nix-community/disko.git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    impermanence = {
      url = "git+ssh://git@github.com/nix-community/impermanence.git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    preservation = {
      url = "git+ssh://git@github.com/WilliButz/preservation.git";
    };

    # Zen Browser
    zen-browser = {
      url = "git+ssh://git@github.com/0xc000022070/zen-browser-flake.git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Spicetify
    spicetify-nix = {
      url = "git+ssh://git@github.com/Gerg-L/spicetify-nix.git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Nix Minecraft
    nix-minecraft = {
      url = "git+ssh://git@github.com/Infinidoge/nix-minecraft.git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Firefox Nightly
    firefox = {
      url = "git+ssh://git@github.com/nix-community/flake-firefox-nightly.git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Noctalia
    noctalia = {
      url = "git+ssh://git@github.com/noctalia-dev/noctalia-shell.git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    noctalia-v5 = {
      url = "git+ssh://git@github.com/noctalia-dev/noctalia.git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Iron Bar
    ironbar = {
      url = "git+ssh://git@github.com/JakeStanger/ironbar.git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Formatting & Linting
    treefmt-nix = {
      url = "git+ssh://git@github.com/numtide/treefmt-nix.git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    pre-commit-hooks = {
      url = "git+ssh://git@github.com/cachix/pre-commit-hooks.nix.git";
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
