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

      useSolarSecrets = hostData.meta.useSolarSecrets or (hostData.meta.useSecrets or true);
      useSaculSecrets = hostData.meta.useSaculSecrets or false;
      useNannyheadSecrets = hostData.meta.useNannyheadSecrets or false;

      useSecrets = useSolarSecrets || useSaculSecrets || useNannyheadSecrets;

      secretsInputName =
        if useSolarSecrets then
          "solar-secrets"
        else if useSaculSecrets then
          "solar-secrets" # Route to solar-secrets temporarily
        else if useNannyheadSecrets then
          "solar-secrets" # Route to solar-secrets temporarily
        else
          null;

      secretsInput =
        if secretsInputName != null && builtins.hasAttr secretsInputName inputs then
          inputs.${secretsInputName}
        else
          null;

      hasPrivateSecrets =
        useSecrets
        && (secretsInput != null)
        && (secretsInput ? outPath)
        && (builtins.pathExists "${secretsInput}/secrets");

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
          inherit useSecrets;
          inherit secretsInput;
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
            (
              { config, ... }:
              {
                nixpkgs.hostPlatform = system;
                networking.hostName = name;
                nixpkgs.config.allowUnfree = true;
                home-manager.useGlobalPkgs = false;
                home-manager.useUserPackages = true;
                home-manager.sharedModules = [
                  {
                    nixpkgs.config = config.nixpkgs.config;
                    nixpkgs.overlays = config.nixpkgs.overlays;
                  }
                ];

                # Set defaults for agenix-rekey so evaluation doesn't fail
                age.rekey = {
                  hostPubkey =
                    let
                      path = if hasPrivateSecrets then "${secretsInput}/hosts/${name}.pub" else "";
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
                  masterIdentities = lib.mkDefault [ "dummy" ];
                };
              }
            )
          ]
          ++ lib.optional isDarwin {
            # Determinate Nix installer manages the Nix daemon and nix.conf on macOS.
            nix.enable = false;
          };
      };
    };

  hostMetas = lib.genAttrs hostDirs (name: import ./${name}/default.nix);

  isHostDarwin =
    name:
    let
      hostData = hostMetas.${name};
      system = hostData.meta.system or "x86_64-linux";
    in
    lib.hasSuffix "-darwin" system;

  nixosHosts = lib.filterAttrs (name: _: !(isHostDarwin name)) hostMetas;
  darwinHosts = lib.filterAttrs (name: _: isHostDarwin name) hostMetas;
in
{
  nixosConfigurations = lib.mapAttrs (name: _: (mkHost name).config) nixosHosts;
  darwinConfigurations = lib.mapAttrs (name: _: (mkHost name).config) darwinHosts;
}
