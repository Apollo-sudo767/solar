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
      # This needs to be host-specific for the new local storage mode.
      # Use a relative path from the flake root.
      localStorageDir = ../../../secrets/rekeyed/${config.networking.hostName};

      # The public keys of the master identities.
      # We use toString and builtins.pathExists for the actual evaluation,
      # but for the rekeying tool to work, it might need them to be discoverable.
      masterIdentities =
        let
          yubikey = ../../../secrets/master/yubikey.pub;
          se = ../../../secrets/master/se.pub;
          dev = ../../../secrets/master/dev.pub;
        in
        (lib.optional (builtins.pathExists yubikey) yubikey)
        ++ (lib.optional (builtins.pathExists se) se)
        ++ (lib.optional (builtins.pathExists dev) dev)
        # Fallback to a dummy if nothing exists yet
        ++ (lib.optional
          (!(builtins.pathExists yubikey) && !(builtins.pathExists se) && !(builtins.pathExists dev))
          (
            builtins.toFile "dummy.txt" "AGE-SECRET-KEY-1UYYT20446YSN3W8DR7GU46AD8H3JDDEL4N0PKAQ24JUQPSF3NTWSY32NRG"
          )
        );

      # Hardware plugins required for rekeying
      agePlugins = [
        pkgs.age-plugin-yubikey
      ]
      ++ lib.optional isDarwin pkgs.age-plugin-se;

      # Identify the host's public key
      hostPubkey =
        let
          se = ../../../secrets/master/se.pub;
          dev = ../../../secrets/master/dev.pub;
          host = ../../../secrets/hosts/${config.networking.hostName}.pub;
        in
        if isDarwin then
          if builtins.pathExists se then
            se
          else
            "age10000000000000000000000000000000000000000000000000000000000"
        else if builtins.pathExists dev then
          dev
        else if builtins.pathExists host then
          host
        else
          "age10000000000000000000000000000000000000000000000000000000000";
    };

    # Permanent, Master-Managed SSH Key (Linux Only)
    age.secrets.host-ssh-key = lib.mkIf (!isDarwin) {
      generator.script = "ssh-ed25519";
      rekeyFile = ../../../secrets/hosts/${config.networking.hostName}.age;
      group = "root";
      mode = "600";
    };

    # Use the identity for decrypting secrets
    age.identityPaths =
      if isDarwin then
        [ ]
      else if config.age.secrets ? host-ssh-key then
        [ config.age.secrets.host-ssh-key.path ]
      else
        [ ];
  };
}
