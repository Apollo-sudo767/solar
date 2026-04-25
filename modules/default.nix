{ lib, isDarwin ? false, ... }:

let
  getNixFiles = dir:
    let
      contents = builtins.readDir dir;
    in
    lib.flatten (lib.mapAttrsToList (name: type:
      let path = "${toString dir}/${name}"; in
      if type == "directory" then
        if name == "hosts" then []
        else if name == "darwin" && !isDarwin then []
        else getNixFiles path
      else if type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix" then
        path
      else []
    ) contents);
in
{
  imports = getNixFiles ./.;
}
