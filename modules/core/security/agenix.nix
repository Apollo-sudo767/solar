{
  config,
  lib,
  pkgs,
  inputs,
  isDarwin,
  isTotal,
  useSecrets ? true,
  ...
}:

let
  cfg = config.myFeatures.core.security.agenix;

  # FIX: Look exclusively at 'inputs' to determine if the private repo exists.
  # This breaks the infinite recursion because it doesn't read from 'config'.
  hasPrivateSecrets =
    (builtins.hasAttr "solar-secrets" inputs) && (inputs.solar-secrets ? outPath) && useSecrets;
in
{
  options.myFeatures.core.security.agenix = {
    enable = lib.mkEnableOption "agenix-rekey for secret management";
    usePrivateSecrets = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to look for secrets inside the private solar-secrets repository input.";
    };
  };

  config = lib.mkMerge [

    # 1. Base agenix configuration (Completely omitted if the flake input isn't accessible)
    (lib.optionalAttrs hasPrivateSecrets {
      age.rekey = {
        storageMode = "local";
        localStorageDir = inputs.self + "/rekeyed/${config.networking.hostName}";

        masterIdentities =
          let
            allPaths = [
              "${inputs.solar-secrets}/master/yubikey.id.pub"
              "${inputs.solar-secrets}/master/mac_se.id.pub"
            ];
            validIdentities = builtins.filter (
              p:
              let
                content = if builtins.pathExists p then builtins.readFile p else "";
              in
              (lib.strings.hasInfix "AGE-PLUGIN-" content) && !(lib.strings.hasInfix "DUMMY" content)
            ) allPaths;
          in
          if validIdentities == [ ] then [ "dummy" ] else validIdentities;

        agePlugins = [
          pkgs.age-plugin-yubikey
        ]
        ++ lib.optional isDarwin pkgs.age-plugin-se;

        extraEncryptionPubkeys =
          let
            masterDir = inputs.solar-secrets + "/master";
          in
          if builtins.pathExists masterDir then
            builtins.concatLists (
              lib.mapAttrsToList (
                name: type:
                if type == "regular" && lib.hasSuffix ".pub" name then
                  [ (lib.strings.trim (builtins.readFile (masterDir + "/${name}"))) ]
                else
                  [ ]
              ) (builtins.readDir masterDir)
            )
          else
            [ ];
      };
    })

    # 2. Cross-platform aliases and identities (Safe everywhere)
    {
      environment.shellAliases = {
        s-rekey = "AGENIX_REKEY_PRIMARY_FLAKE_ROOT=$HOME/src/solar AGENIX_REKEY_SECONDARY_FLAKE_ROOTS=$HOME/src/solar-secrets nix run --override-input solar-secrets path:$HOME/src/solar-secrets --no-write-lock-file $HOME/src/solar#agenix-rekey-rekey && git -C $HOME/src/solar add rekeyed";
        s-sync = "AGENIX_REKEY_PRIMARY_FLAKE_ROOT=$HOME/src/solar AGENIX_REKEY_SECONDARY_FLAKE_ROOTS=$HOME/src/solar-secrets nix run --override-input solar-secrets path:$HOME/src/solar-secrets --no-write-lock-file $HOME/src/solar#agenix-rekey-update-masterkeys";
        s-edit = "AGENIX_REKEY_PRIMARY_FLAKE_ROOT=$HOME/src/solar AGENIX_REKEY_SECONDARY_FLAKE_ROOTS=$HOME/src/solar-secrets nix run --override-input solar-secrets path:$HOME/src/solar-secrets --no-write-lock-file $HOME/src/solar#agenix-rekey-edit --";
        s-gen = "AGENIX_REKEY_PRIMARY_FLAKE_ROOT=$HOME/src/solar AGENIX_REKEY_SECONDARY_FLAKE_ROOTS=$HOME/src/solar-secrets nix run --override-input solar-secrets path:$HOME/src/solar-secrets --no-write-lock-file $HOME/src/solar#agenix-rekey-generate --";
      };

      age.identityPaths = [
        (if isDarwin then "/Users/apollo/.ssh/id_ed25519" else "/home/apollo/.ssh/id_ed25519")
      ]
      ++ lib.optionals (!isDarwin) [
        "/etc/ssh/ssh_host_ed25519_key"
      ]
      ++ lib.optionals (!isDarwin && config.myFeatures.core.system.core-branch.usePersistence) [
        "/persist/etc/ssh/ssh_host_ed25519_key"
      ];
    }

    # 3. Target Host specific service dependencies
    (lib.mkIf cfg.enable {
      services = lib.optionalAttrs (!isDarwin) {
        pcscd.enable = true;
      };
    })
  ];
}
