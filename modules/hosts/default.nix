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

      # 1. Strict language-level check to verify if the secret repo input is actually present
      hasPrivateSecrets = (builtins.hasAttr "solar-secrets" inputs) && (inputs.solar-secrets ? outPath);

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

      preservationModule =
        if isDarwin then
          { lib, ... }:
          {
            options.preservation = lib.mkOption {
              type = lib.types.anything;
              default = { };
              description = "Mock preservation option for Darwin compatibility.";
            };
          }
        else
          inputs.preservation.nixosModules.default;

      diskoModule = if isDarwin then { } else inputs.disko.nixosModules.disko;
    in
    {
      inherit isDarwin;
      config = builder {
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
            diskoModule
            {
              nixpkgs.hostPlatform = system;
              networking.hostName = name;
              nixpkgs.config.allowUnfree = true;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              # Set defaults for agenix-rekey so evaluation doesn't fail
              age.rekey = {
                hostPubkey =
                  let
                    # 2. Fix: Shield the string path interpolation entirely behind the presence check.
                    # If hasPrivateSecrets is false, it points to a harmless dummy string instead of querying inputs.
                    path = if hasPrivateSecrets then "${inputs.solar-secrets}/hosts/${name}.pub" else "";
                  in
                  lib.mkDefault (
                    if hasPrivateSecrets && (builtins.pathExists path) then
                      lib.strings.trim (builtins.readFile path)
                    else
                      # Fallback to a guaranteed valid age public key (for bootstrapping)
                      "age1vdk2uqhss7xuacntfx95rkcplluwzx33mcxr66rdhu0sh5a0e5rsffrf34"
                  );
                storageMode = lib.mkDefault "local";
                localStorageDir = lib.mkDefault (inputs.self + "/rekeyed/${name}");
                masterIdentities = lib.mkDefault [ ];
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
