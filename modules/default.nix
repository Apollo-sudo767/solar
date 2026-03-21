{ lib, ... }:

let
  getModules = dir: 
    let
      contents = builtins.readDir dir;
      files = lib.mapAttrsToList (name: type: 
        if type == "directory" 
        then getModules (dir + "/${name}")
        else if (lib.hasSuffix ".nix" name) && (name != "default.nix")
        then [ (dir + "/${name}") ]
        else []
      ) contents;
    in 
    lib.flatten files;

  allPaths = getModules ./.;

  # This "Shield" prevents the Boolean crash by ensuring 
  # we only import actual modules (sets or functions)
  validModules = lib.filter (path: 
    let 
      content = import path;
    in 
    (builtins.isAttrs content) || (builtins.isFunction content)
  ) allPaths;

in
{
  imports = validModules;
}
