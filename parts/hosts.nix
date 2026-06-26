# parts/hosts.nix
{ inputs, self, ... }:

{
  flake =
    let
      inherit (inputs.nixpkgs-unstable) lib;

      # Execute your automated host loader script
      hostLoader = import ../modules/hosts/default.nix {
        inherit lib inputs;
        globalModules = [ ../modules/default.nix ];
      };
    in
    {
      inherit (hostLoader) nixosConfigurations;
      inherit (hostLoader) darwinConfigurations;
    };
}
