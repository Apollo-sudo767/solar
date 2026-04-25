# flake.nix
{
  description = "Fully Automated Dendritic Flake";

  inputs = {
    # Core nixpkgs channels
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    # Flake Parts
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Home Manager
    home-manager-unstable.url = "github:nix-community/home-manager/master";
    home-manager-stable.url = "github:nix-community/home-manager/release-25.11";

    # Darwin
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Stylix
    stylix-unstable.url = "github:danth/stylix";
    stylix-stable.url = "github:danth/stylix/release-25.11";

    # Secrets Management
    solar-secrets = {
      url = "git+ssh://git@github.com/apollo-sudo767/solar-secrets.git";
      flake = false;
    };

    # Niri
    niri.url = "github:sodiboo/niri-flake";

    # Disko & Impermance
    disko.url = "github:nix-community/disko";
    impermanence.url = "github:nix-community/impermanence";

    # Zen Browser
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Nix Minecraft
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";

  };

  outputs =
    inputs@{
      self,
      nixpkgs-unstable,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ./parts ];

      # Add MacBook (Darwin) support alongside Linux
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { system, ... }:
        {
          _module.args.pkgs = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true; # Required for things like sops or discord
          };
        };

      flake =
        let
          inherit (nixpkgs-unstable) lib;
          hostLoader = import ./modules/hosts/default.nix {
            inherit lib inputs;
            globalModules = [ ./modules/default.nix ];
          };
        in
        {
          nixosConfigurations = hostLoader.nixosConfigurations;
          darwinConfigurations = hostLoader.darwinConfigurations;
        };
    };
}
