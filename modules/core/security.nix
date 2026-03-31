{ config, lib, inputs, ... }:

let
  cfg = config.myFeatures.core.security;
  # Reference the private repo input
  secretsPath = inputs.solar-secrets; 
  # Path for the RAM-only key
  volatileKey = "/run/user/1000/sops/keys.txt";
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  options.myFeatures.core.security.enable = lib.mkEnableOption "Sops-nix Security";

  config = lib.mkIf cfg.enable {
    sops = {
      # Use the common secrets from your private repo
      defaultSopsFile = "${secretsPath}/secrets/common.yaml";
      
      # Use the RAM key if you've run 'seed', otherwise fallback to host SSH
      age.keyFile = lib.mkIf (builtins.pathExists volatileKey) volatileKey;
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      
      # Define secrets used during activation
      secrets."apollo-password" = { neededForUsers = true; };
    };
  };
}
