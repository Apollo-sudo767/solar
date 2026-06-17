# parts/default.nix
{ inputs, lib, ... }:

{
  # 1. Automatically pull in all other files inside this directory
  imports = [
    inputs.agenix-rekey.flakeModule
  ]
  ++ (builtins.filter (path: builtins.baseNameOf path != "default.nix") (
    lib.filesystem.listFilesRecursive ./.
  ));

  # 2. Configure agenix-rekey global settings at the root module scope
  flake.agenix-rekey = {
    masterIdentities = [ "~/.config/age/master-se.txt" ];
    localStorageDir = ./.secrets-storage;
  };

  perSystem =
    { system, ... }:
    {
      # Allow unfree packages globally across all downstream modules
      _module.args.pkgs = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    };
}
