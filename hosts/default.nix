{ lib, inputs, ... }:

let
  hostEntries = builtins.readDir ./.;
  
  # Filter for directories (each folder is a host)
  validHosts = lib.filterAttrs (name: type: type == "directory") hostEntries;

  # Standard builder
  mkHost = name: type: let
    hostPath = ./. + "/${name}";
  in 
  lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; }; 
    modules = [
      (hostPath + "/default.nix") # Load the host's configuration
      ../modules/default.nix      # Load your recursive module scanner
      inputs.home-manager-unstable.nixosModules.home-manager # Default HM
    ];
  };
in
{
  # Map the builder across the found directories
  nixosConfigurations = lib.mapAttrs (name: type: 
    mkHost name type
  ) validHosts;
}
