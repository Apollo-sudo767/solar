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
              "${inputs.solar-secrets}/master/yubikey.id"
              "${inputs.solar-secrets}/master/mac_se.id"
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
        s-rekey = "AGENIX_REKEY_PRIMARY_FLAKE_ROOT=$HOME/src/solar nix run --override-input solar-secrets path:$HOME/src/solar-secrets --no-write-lock-file $HOME/src/solar#agenix-rekey-rekey && git -C $HOME/src/solar add rekeyed";
        s-sync = "AGENIX_REKEY_PRIMARY_FLAKE_ROOT=$HOME/src/solar nix run --override-input solar-secrets path:$HOME/src/solar-secrets --no-write-lock-file $HOME/src/solar#agenix-rekey-update-masterkeys";
        s-edit = "AGENIX_REKEY_PRIMARY_FLAKE_ROOT=$HOME/src/solar nix run --override-input solar-secrets path:$HOME/src/solar-secrets --no-write-lock-file $HOME/src/solar#agenix-rekey-edit --";
        s-gen = "AGENIX_REKEY_PRIMARY_FLAKE_ROOT=$HOME/src/solar nix run --override-input solar-secrets path:$HOME/src/solar-secrets --no-write-lock-file $HOME/src/solar#agenix-rekey-generate --";
      };
    }

    # 2. Target Host Specifics (Only if agenix.enable = true)
    (lib.mkIf cfg.enable {
      age.rekey.hostPubkey =
        let
          path = "${inputs.solar-secrets}/hosts/${config.networking.hostName}.pub";
        in
        if (builtins.hasAttr "solar-secrets" inputs) && (builtins.pathExists path) then
          lib.strings.trim (builtins.readFile path)
        else
          # Fallback to a guaranteed valid age public key (for bootstrapping)
          "age1vdk2uqhss7xuacntfx95rkcplluwzx33mcxr66rdhu0sh5a0e5rsffrf34";

      # Comprehensive identity paths for decryption
      age.identityPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
        "/persist/etc/ssh/ssh_host_ed25519_key"
        "/Users/apollo/.ssh/id_ed25519"
        "/home/apollo/.ssh/id_ed25519"
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
