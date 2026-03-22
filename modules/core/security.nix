{ config, lib, inputs, ... }:

let
  cfg = config.myFeatures.core.security;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  
  options.myFeatures.core.security.enable = lib.mkEnableOption "SSH Host-key Security";

  config = lib.mkIf cfg.enable {
    sops = {
      # This is the path to the private SSH key already on your SSD
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      
      # Point to your actual secrets file in the repo
      defaultSopsFile = ../../secrets/secrets.yaml;
      
      # Optional: prevents sops from looking for a YubiKey/GPG
      gnupg.sshKeyPaths = [ ];
    };
  };
}
