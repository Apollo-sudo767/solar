{ lib, config, inputs, ... }:

let
  allModuleFiles = lib.filter (path: 
    (lib.hasSuffix ".nix" (builtins.toString path)) && 
    (path != ./. + "/default.nix")
  ) (lib.filesystem.listFilesRecursive ./.);

  # The "Double-Agent" user builder
  mkHomeUser = name: userOpts: {
    # Use the version from the host file, OR fall back to the channel's default
    home.stateVersion = if userOpts ? stateVersion 
                        then userOpts.stateVersion 
                        else config.myFeatures.core.channels.defaultState;
                        
    home.username = name;
    home.homeDirectory = "/home/${name}";
    imports = allModuleFiles;
  };
in
{
  imports = allModuleFiles;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users = lib.mapAttrs mkHomeUser config.myFeatures.users;
  };
}
