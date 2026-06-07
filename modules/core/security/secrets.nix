{
  config,
  lib,
  inputs,
  isDarwin,
  isTotal,
  ...
}:

{
  # This module provides a central place to declare your secrets.
  # To implement a secret:
  #   1. Run 'just edit <name>.age' to create the encrypted master file.
  #   2. Uncomment the corresponding block below.
  #   3. Run 'just rekey' to encrypt it for your hosts.
  #   4. 'git add .' to track the new files.

  config = lib.mkIf config.myFeatures.core.security.agenix.enable {
    age.secrets = {

      # --- CORE SYSTEM SECRETS ---

      # Permanent, Master-Managed SSH Key
      # These are generated per-host in the secrets submodule
      host-ssh-key = {
        generator.script = "ssh-ed25519";
        # Use a simple path for generated secrets to avoid evaluation errors
        rekeyFile = ../../../secrets/hosts/${config.networking.hostName}.age;
        group = lib.mkIf (!isDarwin) "wheel";
        mode = "600";
      };

      # --- PER-USER PASSWORDS ---
      # Note: These should contain the hashed password string.
      # Generate hash with: mkpasswd -m sha-512

      # The password-apollo secret acts as the GLOBAL DEFAULT for all users
      # unless they have their own specific password secret defined.
      "password-apollo.age" = {
        rekeyFile =
          let
            p = ../../../secrets/secrets/password-apollo.age;
          in
          builtins.path {
            path = p;
            name = "password-apollo.age";
          };
      };

      # Specific overrides (uncomment to give a user a different password)
      # "password-hephaestus.age" = {
      #   rekeyFile =
      #     let p = ../../../secrets/secrets/password-hephaestus.age; in
      #     builtins.path { path = p; name = "password-hephaestus.age"; };
      # };

      # "password-root.age" = {
      #   rekeyFile =
      #     let p = ../../../secrets/secrets/password-root.age; in
      #     builtins.path { path = p; name = "password-root.age"; };
      # };

      # --- NETWORKING & SERVICES ---

      # "wifi.age" = {
      #   rekeyFile =
      #     let p = ../../../secrets/secrets/wifi.age; in
      #     builtins.path { path = p; name = "wifi.age"; };
      # };

    };
  };
}
