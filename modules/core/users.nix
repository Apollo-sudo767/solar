{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.core.users;
in
{
  # 1. DECLARE the option so Nix knows it exists
  options.myFeatures.core.users = {
    enable = lib.mkEnableOption "Standard User Configuration";
    usernames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "apollo" ];
    };
  };

  # 2. DEFINE what happens when it's enabled
  config = lib.mkIf cfg.enable {
    _module.args.usernames = cfg.usernames;

    # The Home Manager "Bridge" lives here now to keep things dendritic
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup"; # This fixes the Firefox/Zsh collision
      extraSpecialArgs = { inherit inputs; };
      users = lib.genAttrs cfg.usernames (name: { });
    };

    users.users = lib.genAttrs cfg.usernames (name: {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker" "lp" ];
      shell = pkgs.zsh;
    });
  };
}
