{ lib, ... }:

let
  # Recursively find ALL files
  allFiles = lib.filesystem.listFilesRecursive ./.;
  
  # Filter to ensure we ONLY import .nix files and NOT this file itself
  moduleFiles = lib.filter (path: 
    (lib.hasSuffix ".nix" (builtins.toString path)) && 
    (path != ./. + "/default.nix")
  ) allFiles;
in
{
  imports = moduleFiles;
}
