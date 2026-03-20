{ lib, inputs, ... }:

let
  hostFiles = builtins.readDir ./.;
  validHosts = lib.filterAttrs (name: type:
    (type == "regular") && (name != "default.nix")
  ) hostFiles;

  mkHost = name: _: lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      (./. + "/${name}")        # The host file (e.g., desktop.nix)
      ../modules/default.nix    # The global recursive scanner
      inputs.home-manager-unstable.nixosModules.home-manager
    ];
  };
in
{
  nixosConfigurations = lib.mapAttrs mkHost validHosts;
}
