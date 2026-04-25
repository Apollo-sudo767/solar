{ lib, inputs, globalModules }:

let
  # Scan for host folders, ignoring 'shared'
  hostDirs = lib.attrNames (lib.filterAttrs (name: type: 
    type == "directory" && name != "shared"
  ) (builtins.readDir ./.));

  getPkgInput = isStable: if isStable then inputs.nixpkgs-stable else inputs.nixpkgs-unstable;
  
  mkHost = name: 
    let
      # Import the split file
      hostFile = import ./${name}/default.nix;
      
      # Extract the metadata block
      meta = hostFile.meta or { system = "x86_64-linux"; stable = false; };
      
      # Extract the configuration block
      hostModule = hostFile.module;
      
      isDarwin = lib.hasSuffix "-darwin" meta.system;
      pkgs-input = getPkgInput meta.stable;

      builder = if isDarwin then inputs.nix-darwin.lib.darwinSystem else pkgs-input.lib.nixosSystem;
      hmModule = if isDarwin 
        then inputs.home-manager-unstable.darwinModules.home-manager 
        else (if meta.stable then inputs.home-manager-stable else inputs.home-manager-unstable).nixosModules.home-manager;
    in
    builder {
      system = meta.system;
      specialArgs = { 
        inherit inputs isDarwin;
        isStable = meta.stable; 
        pkgs-stable = import inputs.nixpkgs-stable { 
          system = meta.system;
          config.allowUnfree = true; 
        };
      };
      modules = globalModules ++ [
        hostModule # We pass ONLY the module block here, not the whole file!
        hmModule
        ({
          networking.hostName = name;
          nixpkgs.config.allowUnfree = true;
        } // lib.optionalAttrs isDarwin {
          networking.computerName = name;
          networking.localHostName = name;
        })
      ];
    };
in
{
  # Build NixOS branches (filter by checking the meta block)
  nixosConfigurations = lib.filterAttrs (n: v: !lib.hasSuffix "-darwin" ((import ./${n}/default.nix).meta.system or "")) 
    (lib.genAttrs hostDirs (name: mkHost name));

  # Build Mac branches (filter by checking the meta block)
  darwinConfigurations = lib.filterAttrs (n: v: lib.hasSuffix "-darwin" ((import ./${n}/default.nix).meta.system or "")) 
    (lib.genAttrs hostDirs (name: mkHost name));
}
