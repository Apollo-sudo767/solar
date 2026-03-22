{ lib, ... }:

let
  # Recursively find all .nix files except this one
  getNixFiles = dir:
    let
      contents = builtins.readDir dir;
    in
    lib.flatten (lib.mapAttrsToList (name: type:
      let path = "${toString dir}/${name}"; in
      if type == "directory" then
        getNixFiles path
      else if type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix" then
        path
      else []
    ) contents);
in
{
  imports = getNixFiles ./.;
}
