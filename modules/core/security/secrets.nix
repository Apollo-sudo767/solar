{
  config,
  lib,
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
      host-ssh-key = {
        generator.script = "ssh-ed25519";
        rekeyFile = ../../../secrets/hosts/${config.networking.hostName}.age;
        group = if isDarwin then "wheel" else "root";
        mode = "600";
      };

      # --- PER-USER PASSWORDS ---
      # Note: These should contain the hashed password string.
      # Generate hash with: mkpasswd -m sha-512

      # The password-apollo secret acts as the GLOBAL DEFAULT for all users
      # unless they have their own specific password secret defined.
      "password-apollo.age" = {
        rekeyFile = ../../../secrets/secrets/password-apollo.age;
      };

      # Specific overrides (uncomment to give a user a different password)
      # "password-hephaestus.age" = {
      #   rekeyFile = ../../../secrets/secrets/password-hephaestus.age;
      # };

      # "password-root.age" = {
      #   rekeyFile = ../../../secrets/secrets/password-root.age;
      # };

      # --- NETWORKING & SERVICES ---

      # "wifi.age" = {
      #   rekeyFile = ../../../secrets/secrets/wifi.age;
      # };

      # "tailscale.age" = {
      #   rekeyFile = ../../../secrets/secrets/tailscale.age;
      # };

      # "cloudflare.age" = {
      #   rekeyFile = ../../../secrets/secrets/cloudflare.age;
      # };

      # --- DEVELOPMENT ---

      # "github-token.age" = {
      #   rekeyFile = ../../../secrets/secrets/github-token.age;
      # };

      # "cachix.age" = {
      #   rekeyFile = ../../../secrets/secrets/cachix.age;
      # };

    };
  };
}
