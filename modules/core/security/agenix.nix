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
      # The public keys of the master identities that can decrypt the master secrets.
      masterIdentities = [
        (inputs.solar-secrets + "/master/yubikey.pub")
        (inputs.solar-secrets + "/master/se.pub")
      ];

      # Storage for rekeyed (host-specific) secrets.
      localStorageDir = ../../../secrets/rekeyed;

      # Hardware plugins required for rekeying
      agePlugins = [
        pkgs.age-plugin-yubikey
      ] ++ lib.optional isDarwin pkgs.age-plugin-se;

      # Identify the host's public key
      hostPubkey =
        if isDarwin then
          # On Mac, we use the Secure Enclave public key directly
          (inputs.solar-secrets + "/master/se.pub")
        else
          # On Linux, we use the generated permanent SSH key
          (inputs.solar-secrets + "/hosts/${config.networking.hostName}.pub");
    };
  };

  # Permanent, Master-Managed SSH Key (Linux Only)
  # Mac uses the Secure Enclave which is "invincible" and already exists.
  age.secrets.host-ssh-key = lib.mkIf (!isDarwin) {
    generator.script = "ssh-ed25519";
    rekeyFile = inputs.solar-secrets + "/hosts/${config.networking.hostName}.age";
    group = "root";
    mode = "600";
  };

  # Use the identity for decrypting secrets
  age.identityPaths =
    if isDarwin then
      # On Mac, the Secure Enclave plugin handles the identity path
      [ ]
    else
      # On Linux, use our master-managed backup key
      [ config.age.secrets.host-ssh-key.path ];

  # Use the generated key as the actual SSH host key (Linux Only)
  services.openssh.hostKeys = lib.mkIf (!isDarwin) [
    {
      path = config.age.secrets.host-ssh-key.path;
      type = "ed25519";
    }
  ];
  }

}
