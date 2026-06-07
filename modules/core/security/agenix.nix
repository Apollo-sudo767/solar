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
    masterIdentities = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = "List of public keys for rekeying (master identities).";
    };
  };

  config = lib.mkIf cfg.enable {
    age.rekey = {
      storageMode = "local";
      # Storage for rekeyed (host-specific) secrets.
      # This MUST be a local path in the 'solar' repo.
      localStorageDir = ../../../rekeyed-secrets/${config.networking.hostName};

      # The public keys of the master identities.
      # Sourced from the 'solar-secrets' input for cross-system stability.
      masterIdentities =
        let
          s = inputs.solar-secrets;
        in
        (lib.optional (builtins.pathExists (s + "/master/yubikey.pub")) (s + "/master/yubikey.pub"))
        ++ (lib.optional (builtins.pathExists (s + "/master/se.pub")) (s + "/master/se.pub"))
        ++ (lib.optional (builtins.pathExists (s + "/master/dev.txt")) (s + "/master/dev.txt"))
        ++ (lib.optional (
          builtins.pathExists (s + "/master/dev.pub") && !(builtins.pathExists (s + "/master/dev.txt"))
        ) (s + "/master/dev.pub"))
        ++ (lib.optional (builtins.pathExists (s + "/master/mac.pub")) (s + "/master/mac.pub"));

      # Hardware plugins required for rekeying
      agePlugins = [
        pkgs.age-plugin-yubikey
      ]
      ++ lib.optional isDarwin pkgs.age-plugin-se;

      # Identify the host's public key.
      hostPubkey =
        let
          hostPub = inputs.solar-secrets + "/hosts/${config.networking.hostName}.pub";
        in
        if builtins.pathExists hostPub then
          lib.strings.trim (builtins.readFile hostPub)
        else
          config.age.secrets.host-ssh-key.pubkey
            or "age10000000000000000000000000000000000000000000000000000000000";
    };
    # Use the identity for decrypting secrets
    age.identityPaths =
      if isDarwin then
        [ config.age.secrets.host-ssh-key.path ]
      else
        [
          "/persist/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key"
        ];
  };
}
