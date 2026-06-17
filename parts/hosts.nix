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

      # Safely attach nodes back into the global rekey scanning parameters
      agenix-rekey = {
        nixosConfigurations = self.nixosConfigurations or { };
        darwinConfigurations = self.darwinConfigurations or { };
      };
    };
}
