# modules/hosts/default.nix
# ============================================================================
# Automated Host Discovery & System Builder (`mkHost`)
# ============================================================================
# Scans `modules/hosts/` for machine directories (excluding `shared/`), reads
# each host's `{ meta = ...; module = ...; }` definition from `default.nix`,
# and constructs either a NixOS (`nixosConfigurations`) or macOS
# (`darwinConfigurations`) system closure.
{
  lib,
  inputs,
  globalModules,
}:

let
  # --------------------------------------------------------------------------
  # 1. Discover Host Directories
  # --------------------------------------------------------------------------
  # Every subdirectory in `modules/hosts/` (except `shared`, which holds common
  # hardware snippets) represents a machine in the fleet.
  hostDirs = lib.attrNames (
    lib.filterAttrs (name: type: type == "directory" && name != "shared") (builtins.readDir ./.)
  );

  # Import each host's `default.nix` attribute set `{ meta = { ... }; module = ...; }`
  hostMetas = lib.genAttrs hostDirs (name: import ./${name}/default.nix);

  # Select the Nixpkgs channel requested by `meta.stable`
  getPkgInput = isStable: if isStable then inputs.nixpkgs-stable else inputs.nixpkgs-unstable;

  # --------------------------------------------------------------------------
  # 2. Private Secrets Repository & Master Identity Discovery
  # --------------------------------------------------------------------------
  # Check if the private `solar-secrets` flake input is available on disk.
  # When a user forks this repo without access to `solar-secrets` (or overrides
  # it with an empty directory in the ISO installer), `globalSolarSecrets`
  # gracefully falls back so evaluation never fails.
  globalSolarSecrets =
    if (builtins.hasAttr "solar-secrets" inputs) && (inputs.solar-secrets ? outPath) then
      inputs.solar-secrets
    else
      null;

  # Collect hardware master identities (YubiKey / macOS Secure Enclave) for agenix-rekey.
  # Falls back to `[ "dummy" ]` when building without private secrets so `age.rekey`
  # option validation still succeeds.
  globalMasterIdentities =
    let
      allPaths =
        if globalSolarSecrets != null && (builtins.pathExists "${globalSolarSecrets}/master") then
          [
            "${globalSolarSecrets}/master/yubikey.id.pub"
            "${globalSolarSecrets}/master/yubikey_slot2.id.pub"
            "${globalSolarSecrets}/master/mac_se.id.pub"
          ]
        else
          [ ];
      validIdentities = builtins.filter (
        p:
        let
          content = if builtins.pathExists p then builtins.readFile p else "";
        in
        (lib.strings.hasInfix "AGE-PLUGIN-" content) && !(lib.strings.hasInfix "DUMMY" content)
      ) allPaths;
    in
    if validIdentities == [ ] then [ "dummy" ] else validIdentities;

  # --------------------------------------------------------------------------
  # 3. Per-Host System Builder (`mkHost`)
  # --------------------------------------------------------------------------
  mkHost =
    name: hostData:
    let
      # Extract peekable metadata from `meta` (with sensible defaults)
      system = hostData.meta.system or "x86_64-linux";
      isStable = hostData.meta.stable or false;
      isDarwin = lib.hasSuffix "-darwin" system;

      # Allow hosts to opt out of private secrets via `meta.useSolarSecrets = false;`
      # (or legacy alias `meta.useSecrets = false;`).
      useSecrets = hostData.meta.useSolarSecrets or (hostData.meta.useSecrets or true);
      secretsInput = if useSecrets then globalSolarSecrets else null;

      hasPrivateSecrets =
        useSecrets
        && (secretsInput != null)
        && (secretsInput ? outPath)
        && (builtins.pathExists "${secretsInput}/secrets");

      # Choose the OS builder and matching Home Manager / Agenix modules for the platform
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

      # Linux-only external NixOS modules (mocked or omitted on macOS)
      preservationModule =
        if isDarwin then
          { lib, ... }:
          {
            options.preservation = lib.mkOption {
              type = lib.types.anything;
              default = { };
              description = "No-op preservation option stub for Darwin evaluation compatibility.";
            };
          }
        else
          inputs.preservation.nixosModules.default;

      diskoModule = if isDarwin then { } else inputs.disko.nixosModules.disko;
      flatpakModule = if isDarwin then { } else inputs.nix-flatpak.nixosModules.nix-flatpak;
    in
    {
      config = builder {
        # `specialArgs` are passed to every module in the evaluation (including
        # `modules/default.nix`, which requires `isDarwin` to filter imports).
        specialArgs = {
          inherit
            inputs
            isStable
            isDarwin
            useSecrets
            secretsInput
            ;
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
            flatpakModule
            (_: {
              nixpkgs.hostPlatform = lib.mkDefault system;
              networking.hostName = lib.mkDefault name;
              nixpkgs.config.allowUnfree = lib.mkDefault true;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              # Baseline `age.rekey` defaults so `agenix-rekey` evaluation succeeds
              # even on hosts that disable secrets or are being bootstrapped for the first time.
              age.rekey = {
                hostPubkey =
                  let
                    path = if hasPrivateSecrets then "${secretsInput}/hosts/${name}.pub" else "";
                  in
                  lib.mkDefault (
                    if hasPrivateSecrets && (builtins.pathExists path) then
                      lib.strings.trim (builtins.readFile path)
                    else
                      # Fallback valid age public key for initial bootstrapping / CI evaluation
                      "age1vdk2uqhss7xuacntfx95rkcplluwzx33mcxr66rdhu0sh5a0e5rsffrf34"
                  );
                storageMode = lib.mkDefault "local";
                localStorageDir = lib.mkDefault (inputs.self + "/rekeyed/${name}");
                masterIdentities = lib.mkDefault globalMasterIdentities;
              };
            })
          ]
          ++ lib.optional isDarwin {
            # Determinate Nix installer manages the Nix daemon and nix.conf on macOS.
            nix.enable = false;
          };
      };
    };

  # Partition discovered hosts into Linux (`nixosConfigurations`) and macOS (`darwinConfigurations`)
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
  nixosConfigurations = lib.mapAttrs (name: hostData: (mkHost name hostData).config) nixosHosts;
  darwinConfigurations = lib.mapAttrs (name: hostData: (mkHost name hostData).config) darwinHosts;
}
