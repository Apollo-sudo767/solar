{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.core.users;
in
{
  options.myFeatures.core.users = {
    enable = lib.mkEnableOption "Standard User Configuration";
    usernames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "apollo" ];
    };
  };

  config = lib.mkIf cfg.enable {
    nix.settings.trusted-users = [ "root" ] ++ cfg.usernames;
    users.users = lib.genAttrs cfg.usernames (name: {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker" "lp" ];
      shell = pkgs.zsh;
    });
  };
}
