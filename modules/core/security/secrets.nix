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

      # Permanent, Master-Managed SSH Key (Darwin Only)
      # Linux uses injected keys in /persist/etc/ssh to avoid circular dependency
      host-ssh-key = lib.mkIf isDarwin {
        generator.script = "ssh-ed25519";
        rekeyFile = ../../../secrets/hosts/${config.networking.hostName}.age;
        group = "wheel";
        mode = "600";
      };

      # --- PER-USER PASSWORDS ---
      # Note: These should contain the hashed password string.
      # Generate hash with: mkpasswd -m sha-512

      # The password-apollo secret acts as the GLOBAL DEFAULT for all users
      # unless they have their own specific password secret defined.
      "password-apollo.age" = {
        rekeyFile = builtins.path {
          path = ../../../secrets/secrets/password-apollo.age;
          name = "password-apollo.age";
        };
      };

      # Specific overrides (uncomment to give a user a different password)
      # "password-hephaestus.age" = {
      #   rekeyFile = builtins.path {
      #     path = ../../../secrets/secrets/password-hephaestus.age;
      #     name = "password-hephaestus.age";
      #   };
      # };

      # "password-root.age" = {
      #   rekeyFile = builtins.path {
      #     path = ../../../secrets/secrets/password-root.age;
      #     name = "password-root.age";
      #   };
      # };

      # --- NETWORKING & SERVICES ---

      # "wifi.age" = {
      #   rekeyFile = builtins.path {
      #     path = ../../../secrets/secrets/wifi.age;
      #     name = "wifi.age";
      #   };
      # };
    };
  };
}
