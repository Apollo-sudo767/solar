{ lib, config, inputs, ... }:

let
  # Recursive scanner for all .nix files in /modules/ (excluding this one)
  allModuleFiles = lib.filter (path: 
    (lib.hasSuffix ".nix" (builtins.toString path)) && 
    (path != ./. + "/default.nix")
  ) (lib.filesystem.listFilesRecursive ./.);

  # Helper to configure a Home-Manager user
  mkHomeUser = userOpts: {
    inherit (userOpts) stateVersion;
    home.username = userOpts.name;
    home.homeDirectory = "/home/${userOpts.name}";
    imports = allModuleFiles; # Every user gets the full feature library
  };
in
{
  # 1. Import all files as NixOS System Modules
  imports = allModuleFiles;

  # 2. Dynamically generate Home-Manager users based on host config
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    # Map over the 'myFeatures.users' list defined in your host file
    users = lib.mapAttrs (name: userOpts: 
      mkHomeUser (userOpts // { inherit name; })
    ) config.myFeatures.users;
  };
}
