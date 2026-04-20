{ lib, inputs, globalModules }:

let
  hostDirs = lib.attrNames (lib.filterAttrs (name: type: 
    type == "directory"
  ) (builtins.readDir ./.));

  getPkgInput = isStable: if isStable then inputs.nixpkgs-stable else inputs.nixpkgs-unstable;
  getHMInput  = isStable: if isStable then inputs.home-manager-stable else inputs.home-manager-unstable;

  mkHost = name: 
    let
      machine = import ./${name}/settings.nix;
      isStable = machine.stable or false;
      pkgs-input = getPkgInput isStable;
      isDarwin = lib.strings.hasInfix "darwin" machine.system;
      
      # Select the builder based on the system type
      builder = if isDarwin then inputs.nix-darwin.lib.darwinSystem else pkgs-input.lib.nixosSystem;
      
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
          # Networking.hostName is platform-dependent; nix-darwin uses networking.computerName
          networking = if isDarwin then { computerName = name; hostName = name; } else { hostName = name; };
          nixpkgs.config.allowUnfree = true;
        }
      ];
    in
    {
      inherit isDarwin;
      value = builder {
        system = machine.system;
        inherit specialArgs modules;
      };
    };

  # Generate both sets of configurations
  allHosts = lib.genAttrs hostDirs (name: mkHost name);
in
{
  nixosConfigurations = lib.mapAttrs (name: v: v.value) (lib.filterAttrs (name: v: !v.isDarwin) allHosts);
  darwinConfigurations = lib.mapAttrs (name: v: v.value) (lib.filterAttrs (name: v: v.isDarwin) allHosts);
}
