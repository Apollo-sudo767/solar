{ config, pkgs, ... }: {
  config = lib.mkIf config.myFeatures.core.security.enable {
    # Install the plugin so the system can talk to the key
    environment.systemPackages = [ pkgs.age-plugin-yubikey ];

    sops = {
      # This tells sops-nix to use the YubiKey plugin for decryption
      age.sshKeyPaths = [ ]; # We aren't using SSH keys anymore
      age.keyFile = "/var/lib/sops-nix/key.txt"; # Optional backup
      
      # Use the plugin specifically
      gnupg.sshKeyPaths = [ ]; 
    };
    
    # Ensure pcscd is running (required for YubiKey/Smartcards)
    services.pcscd.enable = true;
  };
}
