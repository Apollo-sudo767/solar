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

    # Stylix
    stylix-unstable.url = "github:danth/stylix";
    stylix-stable.url = "github:danth/stylix/release-25.11";

    # Sops-nix
    sops-nix.url = "github:Mic92/sops-nix";
    solar-secrets = {
      url= "git+ssh://git@github.com/apollo-sudo767/solar-secrets.git";
      flake = false;
    };
    
    # Niri
    niri.url = "github:sodiboo/niri-flake";

    # Disko & Impermance
    disko.url = "github:nix-community/disko"; #
    impermanence.url = "github:nix-community/impermanence"; #

    # Zen Browser
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Nix Minecraft
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    
  };

  outputs = { self, nixpkgs-unstable, ... }@inputs: 
    let
      inherit (nixpkgs-unstable) lib;
      
      # We import the host loader here
      hostLoader = import ./hosts/default.nix {
        inherit lib inputs;
        # We pass the path to the modules/default.nix here
        globalModules = [ ./modules/default.nix ]; 
      };
    in {
      nixosConfigurations = hostLoader.nixosConfigurations;
    };
}
