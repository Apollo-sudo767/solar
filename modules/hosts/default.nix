# hosts/default.nix
{
  lib,
  inputs,
  globalModules,
}:

let
  hostDirs = lib.attrNames (
    lib.filterAttrs (name: type: type == "directory" && name != "shared") (builtins.readDir ./.)
  );

  getPkgInput = isStable: if isStable then inputs.nixpkgs-stable else inputs.nixpkgs-unstable;

  mkHost =
    name:
    let
      hostData = import ./${name}/default.nix;
      # Extract metadata from the host's 'meta' set
      system = hostData.meta.system or "x86_64-linux";
      isStable = hostData.meta.stable or false;

      # Determine platform
      isDarwin = lib.hasSuffix "-darwin" system;

      pkgs-input = getPkgInput isStable;
      builder = if isDarwin then inputs.nix-darwin.lib.darwinSystem else pkgs-input.lib.nixosSystem;

      hmInput = if isStable then inputs.home-manager-stable else inputs.home-manager-unstable;
      hmModule =
        if isDarwin then hmInput.darwinModules.home-manager else hmInput.nixosModules.home-manager;

      agenixModule =
        if isDarwin then inputs.agenix.darwinModules.default else inputs.agenix.nixosModules.default;

      agenixRekeyModule =
        if isDarwin then
          inputs.agenix-rekey.darwinModules.default
        else
          inputs.agenix-rekey.nixosModules.default;

      preservationModule = if isDarwin then { } else inputs.preservation.nixosModules.default;
    in
    {
      inherit isDarwin;
      config = builder {
        inherit system;
        # Pass flags: isDarwin for Mac, isTotal for both
        specialArgs = {
          inherit inputs isStable isDarwin;
          isTotal = true;
          inherit (inputs) preservation;
        };
        modules =
          globalModules
          ++ [
            (hostData.module or { })
            hmModule
            agenixModule
            agenixRekeyModule
            preservationModule
            {
              networking.hostName = name;
              nixpkgs.config.allowUnfree = true;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              # Set defaults for agenix-rekey so evaluation doesn't fail
              age.rekey = {
                storageMode = lib.mkDefault "local";
                localStorageDir = lib.mkDefault (inputs.self + "/secrets/rekeyed/${name}");
              };
            }
          ]
          ++ lib.optional isDarwin {
            # Determinate Nix installer manages the Nix daemon and nix.conf on macOS.
            nix.enable = false;
          };
      };
    };

  allHosts = lib.genAttrs hostDirs mkHost;
in
{
  nixosConfigurations = lib.mapAttrs (_n: v: v.config) (
    lib.filterAttrs (_n: v: !v.isDarwin) allHosts
  );

  darwinConfigurations = lib.mapAttrs (_n: v: v.config) (
    lib.filterAttrs (_n: v: v.isDarwin) allHosts
  );
}
