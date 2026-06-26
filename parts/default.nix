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

}
