{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.systems.swaylock;
in {
  options.myFeatures.systems.swaylock = {
    enable = lib.mkEnableOption "swaylock screen locker";
    image = lib.mkOption {
      type = lib.types.path;
      default = ../../assets/wallpapers/gruvbox.jpg; 
    };
  };

  config = lib.mkIf cfg.enable {
    # This dynamically loops over whatever usernames are defined for the CURRENT host
    home-manager.users = lib.genAttrs config.myFeatures.core.users.usernames (name: {
      programs.swaylock = {
        enable = true;
        package = pkgs.swaylock-effects;
        settings = lib.mkForce {
          image = "${cfg.image}";
          scaling = "fill";
          color = "282828";
          ring-color = "fabd2f";
          key-hl-color = "fb4934";
          line-color = "00000000";
          inside-color = "00000000";
          separator-color = "00000000";
          # Effects
          screenshots = true;
          clock = true;
          indicator = true;
          indicator-radius = 100;
          indicator-thickness = 7;
          effect-blur = "7x5";
          effect-vignette = "0.5:0.5";
        };
      };
    });
  };
}
