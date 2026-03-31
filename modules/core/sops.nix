{ config, lib, inputs, ... }:

let
  cfg = config.myFeatures.core.sops;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  
  options.myFeatures.core.sops.enable = lib.mkEnableOption "SOPS Secrets";

  config = lib.mkIf cfg.enable {
    sops = {
      # This points to the content provided by the github:apollo-sudo767/solar-secrets input
      defaultSopsFile = "${inputs.solar-secrets}/secrets/common.yaml";
      
      # Use the same hardware key for decryption that you use for fetching
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      gnupg.sshKeyPaths = [ ];
    };
  };
}
