# parts/secrets.nix
{ inputs, self, ... }:

{
  # 1. Global Flake Module Configuration (Must be outside perSystem!)
  flake.agenix-rekey = {
    # Points the engine to your local MacBook Secure Enclave identity path
    masterIdentities = [ "~/.config/age/master-se.txt" ];

    # Storage definition for generated public key mappings
    localStorageDir = ../.secrets-storage;

    # Scan nodes directly from your flake's exposed configurations
    nixosConfigurations = self.nixosConfigurations or { };
    darwinConfigurations = self.darwinConfigurations or { };
  };

  # 2. Per-System Applications Definition
  perSystem =
    { system, lib, ... }:
    {
      apps = {
        generate = {
          type = "app";
          program = lib.getExe inputs.agenix-rekey.packages.${system}.generate;
        };
        rekey = {
          type = "app";
          program = lib.getExe inputs.agenix-rekey.packages.${system}.rekey;
        };
        edit = {
          type = "app";
          program = lib.getExe inputs.agenix-rekey.packages.${system}.edit-view;
        };
      };
    };
}
