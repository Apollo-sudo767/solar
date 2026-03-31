{ lib, inputs, globalModules }:

let
  # 1. Discover all directories in the current folder (hosts/), excluding "shared"
  hostDirs = lib.filter (name: 
    let 
      type = (builtins.readDir ./.).${name};
    in 
    type == "directory" && name != "shared"
  ) (lib.attrNames (builtins.readDir ./.));

  # 2. Helper to select inputs based on a boolean
  getPkgInput = isStable: if isStable then inputs.nixpkgs-stable else inputs.nixpkgs-unstable;
  getHMInput  = isStable: if isStable then inputs.home-manager-stable else inputs.home-manager-unstable;

  # 3. The generator function
  mkHost = name: 
    let
      machine = import ./${name}/settings.nix;
      isStable = machine.stable or false;
      pkgs-input = getPkgInput isStable;
    in
    pkgs-input.lib.nixosSystem {
      inherit (machine) system;
      specialArgs = { 
        inherit inputs isStable;
        pkgs-stable = import inputs.nixpkgs-stable { 
          inherit (machine) system; 
          config.allowUnfree = true; 
        };
      };
      modules = globalModules ++ [
        ./${name} 
        (getHMInput isStable).nixosModules.home-manager
        {
          networking.hostName = name;
          nixpkgs.config.allowUnfree = true;
        }
      ];
    };
in
{
  # 4. Map discovered directories to nixosConfigurations
  nixosConfigurations = lib.genAttrs hostDirs (name: mkHost name);
}
