{
  config,
  lib,
  pkgs,
  inputs,
  isDarwin,
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
      # The public keys of the master identities.
      # We use toString to ensure they are treated as paths/strings, not modules.
      masterIdentities =
        let
          yubikey = "${inputs.solar-secrets}/master/yubikey.pub";
          se = "${inputs.solar-secrets}/master/se.pub";
        in
        (lib.optional (builtins.pathExists yubikey) yubikey)
        ++ (lib.optional (builtins.pathExists se) se)
        # Fallback to an empty list if nothing exists yet
        ++ (lib.optional (!(builtins.pathExists yubikey) && !(builtins.pathExists se)) (
          toString (pkgs.writeText "dummy.pub" "age10000000000000000000000000000000000000000000000000000000000")
        ));

      # Storage for rekeyed (host-specific) secrets.
      localStorageDir = ../../../secrets/rekeyed;

      # Hardware plugins required for rekeying
      agePlugins = [
        pkgs.age-plugin-yubikey
      ] ++ lib.optional isDarwin pkgs.age-plugin-se;

      # Identify the host's public key
      hostPubkey =
        let
          se = "${inputs.solar-secrets}/master/se.pub";
          host = "${inputs.solar-secrets}/hosts/${config.networking.hostName}.pub";
        in
        if isDarwin then
          if builtins.pathExists se then se else (toString (pkgs.writeText "dummy-se.pub" "age10000000000000000000000000000000000000000000000000000000000"))
        else if builtins.pathExists host then
          host
        else
          (toString (pkgs.writeText "dummy-host.pub" "age10000000000000000000000000000000000000000000000000000000000"));
    };

    # Permanent, Master-Managed SSH Key (Linux Only)
    age.secrets.host-ssh-key = lib.mkIf (!isDarwin) {
      generator.script = "ssh-ed25519";
      rekeyFile = inputs.solar-secrets + "/hosts/${config.networking.hostName}.age";
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
