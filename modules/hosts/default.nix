{ lib, inputs, globalModules }:

let
  hostDirs = lib.attrNames (lib.filterAttrs (name: type: 
    type == "directory" && name != "shared"
  ) (builtins.readDir ./.));

  getPkgInput = isStable: if isStable then inputs.nixpkgs-stable else inputs.nixpkgs-unstable;
  
  mkHost = name: 
    let
      hostFile = import ./${name}/default.nix;
      # Debug: This will print the detected system to your console
      system = hostFile.meta.system or hostFile.system or "x86_64-linux";
      _debug = builtins.trace "Host: ${name} | System: ${system}" system; 
      
      isStable = hostFile.meta.stable or hostFile.stable or false;
      isDarwin = lib.hasSuffix "-darwin" system;
      
      pkgs-input = getPkgInput isStable;
      builder = if isDarwin then inputs.nix-darwin.lib.darwinSystem else pkgs-input.lib.nixosSystem;
      
      hmModule = if isDarwin 
        then inputs.home-manager-unstable.darwinModules.home-manager 
        else (if isStable then inputs.home-manager-stable else inputs.home-manager-unstable).nixosModules.home-manager;
    in
    {
      inherit isDarwin;
      config = builder {
        inherit system;
        specialArgs = { inherit inputs isStable isDarwin; };
        modules = globalModules ++ [
          (hostFile.module or { }) 
          hmModule
          {
            networking.hostName = name;
            nixpkgs.config.allowUnfree = true;
          }
        ];
      };
    };

  allHosts = lib.genAttrs hostDirs (name: mkHost name);
in
{
  nixosConfigurations = lib.mapAttrs (n: v: v.config) 
    (lib.filterAttrs (n: v: !v.isDarwin) allHosts);

  darwinConfigurations = lib.mapAttrs (n: v: v.config) 
    (lib.filterAttrs (n: v: v.isDarwin) allHosts);
}
