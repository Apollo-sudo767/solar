{ config, lib, pkgs, inputs, isStable ? true, ... }: # Note the ? true fallback here

let
  cfg = config.myFeatures.core.users;
  # Set a definite default if isStable is not passed correctly
  dynamicVersion = if isStable then "25.11" else "26.05";
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
    _module.args.usernames = cfg.usernames;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";
      extraSpecialArgs = { inherit inputs; };

      # Assign the mandatory stateVersion to every user
      users = lib.genAttrs cfg.usernames (name: {
        home.stateVersion = dynamicVersion;
      });
    };
    users.users = lib.genAttrs cfg.usernames (name: {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker" "lp" ];
      shell = pkgs.zsh;
    });

  };
}
