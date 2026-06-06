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
      localStorageDir = ../../../secrets/rekeyed/${config.networking.hostName};

      # The public keys of the master identities.
      masterIdentities =
        let
          yubikey = ../../../secrets/master/yubikey.pub;
          se = ../../../secrets/master/se.pub;
          dev = ../../../secrets/master/dev.pub;
          devTxt = ../../../secrets/master/dev.txt;
          mac = ../../../secrets/master/mac.pub;
        in
        (lib.optional (builtins.pathExists yubikey) yubikey)
        ++ (lib.optional (builtins.pathExists se) se)
        ++ (lib.optional (builtins.pathExists devTxt) devTxt)
        ++ (lib.optional (builtins.pathExists dev && !(builtins.pathExists devTxt)) dev)
        ++ (lib.optional (builtins.pathExists mac) mac);

      # Hardware plugins required for rekeying
      agePlugins = [
        pkgs.age-plugin-yubikey
      ]
      ++ lib.optional isDarwin pkgs.age-plugin-se;

      # Identify the host's public key. We prefer the generated host-ssh-key.
      hostPubkey =
        let
          hostPub = ../../../secrets/hosts/${config.networking.hostName}.pub;
        in
        if builtins.pathExists hostPub then
          hostPub
        else
          config.age.secrets.host-ssh-key.pubkey
            or "age10000000000000000000000000000000000000000000000000000000000";
    };

    # Use the identity for decrypting secrets
    age.identityPaths = [ config.age.secrets.host-ssh-key.path ];
  };
}
