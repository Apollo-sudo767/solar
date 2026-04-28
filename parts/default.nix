# parts/default.nix
{ lib, ... }:

{
  # Only import files that aren't this one to prevent infinite recursion
  imports = builtins.filter (path: builtins.baseNameOf path != "default.nix") (
    lib.filesystem.listFilesRecursive ./.
  );
}
