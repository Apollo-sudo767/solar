{
  description = "Fully Automated Dendritic Flake";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    # Add nix-darwin
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager-unstable.url = "github:nix-community/home-manager/master";
    home-manager-stable.url = "github:nix-community/home-manager/release-25.11";

    stylix-unstable.url = "github:danth/stylix";
    stylix-stable.url = "github:danth/stylix/release-25.11";

    sops-nix.url = "github:Mic92/sops-nix";
    niri.url = "github:sodiboo/niri-flake";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs-unstable, nix-darwin, ... }@inputs: 
    let
      inherit (nixpkgs-unstable) lib;
      hostLoader = import ./hosts/default.nix {
        inherit lib inputs;
        globalModules = [ ./modules/default.nix ];
      };
    in {
      nixosConfigurations = hostLoader.nixosConfigurations;
      darwinConfigurations = hostLoader.darwinConfigurations;
    };
}
