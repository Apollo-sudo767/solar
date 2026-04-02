{ config, lib, pkgs, inputs, isStable ? true, ... }:

let
  cfg = config.myFeatures.core.persistentUsers;
  dynamicVersion = if isStable then "25.11" else "26.05";
in
{
  options.myFeatures.core.persistentUsers = {
    enable = lib.mkEnableOption "Persistent Users with SOPS passwords";
    usernames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "apollo" ];
    };
  };

  config = lib.mkIf cfg.enable {
    # Register secrets for the users
    sops.secrets.apollo-password.neededForUsers = true;
    sops.secrets.root-password.neededForUsers = true;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = { inherit inputs; };
      
      users = lib.genAttrs cfg.usernames (name: {
        home.stateVersion = dynamicVersion;
      });
    };

    users.users = (lib.genAttrs cfg.usernames (name: {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker" "lp" ];
      shell = pkgs.zsh;
      hashedPasswordFile = config.sops.secrets."${name}-password".path;
    })) // {
      root.hashedPasswordFile = config.sops.secrets.root-password.path;
    };

    environment.persistence."/nix/persist" = {
      files = [
        "/etc/passwd"
        "/etc/shadow"
        "/etc/group"
      ];
    };
  };
}
