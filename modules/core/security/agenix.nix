{
  config,
  lib,
  pkgs,
  inputs,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.core.security.agenix;
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
    # 1. Global Secret Management (Available on all hosts for apps/aliases)
    {
      age.rekey = {
        storageMode = "local";
        localStorageDir = inputs.self + "/rekeyed/${config.networking.hostName}";

        masterIdentities =
          let
            allPaths = [
              "${inputs.solar-secrets}/master/yubikey.id.pub"
              "${inputs.solar-secrets}/master/mac_se.id.pub"
            ];
            # Only include if file exists, has AGE-PLUGIN, and is NOT a dummy
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
          if cfg.usePrivateSecrets && (builtins.hasAttr "solar-secrets" inputs) then
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
              [ ]
          else
            [ ];
      };

      # Convenience Aliases for Secret Management
      environment.shellAliases = {
        s-rekey = "AGENIX_REKEY_PRIMARY_FLAKE_ROOT=$HOME/src/solar AGENIX_REKEY_SECONDARY_FLAKE_ROOTS=$HOME/src/solar-secrets nix run --override-input solar-secrets path:$HOME/src/solar-secrets --no-write-lock-file $HOME/src/solar#agenix-rekey-rekey && git -C $HOME/src/solar add rekeyed";
        s-sync = "AGENIX_REKEY_PRIMARY_FLAKE_ROOT=$HOME/src/solar AGENIX_REKEY_SECONDARY_FLAKE_ROOTS=$HOME/src/solar-secrets nix run --override-input solar-secrets path:$HOME/src/solar-secrets --no-write-lock-file $HOME/src/solar#agenix-rekey-update-masterkeys";
        s-edit = "AGENIX_REKEY_PRIMARY_FLAKE_ROOT=$HOME/src/solar AGENIX_REKEY_SECONDARY_FLAKE_ROOTS=$HOME/src/solar-secrets nix run --override-input solar-secrets path:$HOME/src/solar-secrets --no-write-lock-file $HOME/src/solar#agenix-rekey-edit --";
        s-gen = "AGENIX_REKEY_PRIMARY_FLAKE_ROOT=$HOME/src/solar AGENIX_REKEY_SECONDARY_FLAKE_ROOTS=$HOME/src/solar-secrets nix run --override-input solar-secrets path:$HOME/src/solar-secrets --no-write-lock-file $HOME/src/solar#agenix-rekey-generate --";
      };
    }

    # Target Host Specifics (Only if agenix.enable = true)
    (lib.mkIf cfg.enable {
      # Comprehensive identity paths for decryption
      age.identityPaths = [
        (if isDarwin then "/Users/apollo/.ssh/id_ed25519" else "/home/apollo/.ssh/id_ed25519")
      ]
      ++ lib.optionals (!isDarwin) [
        "/etc/ssh/ssh_host_ed25519_key"
      ]
      ++ lib.optionals (!isDarwin && config.myFeatures.core.system.core-branch.usePersistence) [
        "/persist/etc/ssh/ssh_host_ed25519_key"
      ];

      # Platform-specific configurations
      preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
        lib.mkIf (!isDarwin && config.myFeatures.core.system.preservation.enable)
          {
            directories = [
              {
                directory = "/etc/ssh";
                mode = "0755";
              }
            ];
            files = [
              "/etc/ssh/ssh_host_ed25519_key"
              "/etc/ssh/ssh_host_ed25519_key.pub"
            ];
          };

      # Linux-Only Services
      services = lib.optionalAttrs (!isDarwin) {
        # Enable pcscd for YubiKey support
        pcscd.enable = true;
      };
    })
  ];
}
