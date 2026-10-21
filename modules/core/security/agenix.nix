# modules/core/security/agenix.nix
# ============================================================================
# Agenix & Agenix-Rekey Secret Management Foundation
# ============================================================================
# Configures hardware-backed secret decryption (`agenix` + `agenix-rekey`):
# - Baseline `age.rekey` settings (`hostPubkey`, `storageMode`, `localStorageDir`,
#   and `masterIdentities`) are defined globally in `modules/hosts/default.nix`.
# - This module adds hardware `agePlugins` (YubiKey / macOS Secure Enclave),
#   `extraEncryptionPubkeys` from `solar-secrets/master/*.pub`, convenient
#   shell aliases (`s-rekey`, `s-sync`, `s-edit`, `s-gen`), SSH host identity
#   paths for boot-time decryption, and the `pcscd` smartcard daemon on Linux.
{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  useSecrets ? true,
  secretsInput ? null,
  ...
}:

let
  cfg = config.myFeatures.core.security.agenix;

  # Inspect `secretsInput` (from `specialArgs`) rather than `config` to avoid
  # infinite recursion while checking whether private secrets are available.
  hasPrivateSecrets =
    useSecrets
    && (secretsInput != null)
    && (secretsInput ? outPath)
    && (builtins.pathExists "${secretsInput}/secrets");
in
{
  options.myFeatures.core.security.agenix = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.myFeatures.core.system.users.agenixPassword;
      description = "Enable agenix-rekey secret management for this host.";
    };
    usePrivateSecrets = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to load secrets from the private `solar-secrets` repository input.";
    };
    enableGithubToken = lib.mkOption {
      type = lib.types.bool;
      default = lib.elem config.networking.hostName [
        "pluto"
        "styx"
        "hydra"
        "mercury"
        "mars"
      ];
      description = "Whether to provision `github-token.age` for authenticated Nix and Git access.";
    };
  };

  config = lib.mkIf isTotal (
    lib.mkMerge [
      # 1. Hardware Age Plugins & Master Pubkeys (Only when private secrets repo is present)
      # Note: `hostPubkey`, `storageMode`, `localStorageDir`, and `masterIdentities`
      # are already configured with `lib.mkDefault` in `modules/hosts/default.nix`.
      (lib.optionalAttrs hasPrivateSecrets {
        age.rekey = {
          agePlugins = [
            pkgs.age-plugin-yubikey
          ]
          ++ lib.optional isDarwin pkgs.age-plugin-se;

          extraEncryptionPubkeys =
            let
              masterDir = secretsInput + "/master";
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

      # 2. Cross-Platform Management Aliases & Decryption Identity Paths
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

      # 3. Smartcard Daemon for YubiKey Operations (Linux-only)
      (lib.mkIf cfg.enable {
        services = lib.optionalAttrs (!isDarwin) {
          pcscd.enable = true;
        };
      })
    ]
  );
}
