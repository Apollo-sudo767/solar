{ inputs, ... }:

{
  imports = [
    inputs.agenix-rekey.flakeModule
  ];

  perSystem =
    {
      pkgs,
      system,
      config,
      ...
    }:
    {
      # 1. Provide the essential enclave packages to your system environment
      environment.systemPackages = [
        inputs.agenix.packages.${system}.default
        inputs.agenix-rekey.packages.${system}.default
        pkgs.age
        pkgs.age-plugin-se
      ];

      # 2. Configure agenix-rekey global settings
      # Following Option Reference_8 for agenix-rekey framework structure
      agenix-rekey = {
        # This points the rekey tool to your master enclave claim identity
        masterIdentities = [ "~/.config/age/master-se.txt" ];

        # Storage definition for generated public tracking keys
        localStorageDir = ../.secrets-storage;
      };
    };
}
