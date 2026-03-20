{ lib, inputs, globalModules, ... }:

let
  hostFiles = builtins.readDir ./.;
  
  validHosts = lib.filterAttrs (name: type:
    (type == "regular" || type == "symlink") && 
    (lib.hasSuffix ".nix" name) && 
    (name != "default.nix")
  ) hostFiles;

  mkHost = name: _: lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      (./. + "/${name}") # The specific machine file
    ] ++ globalModules;   # This injects /modules/default.nix into every host
  };
in
{
  nixosConfigurations = lib.mapAttrs mkHost validHosts;
}
