{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.systems.swaylock;
in {
  options.myFeatures.systems.swaylock = {
    enable = lib.mkEnableOption "swaylock screen locker";
    image = lib.mkOption {
      type = lib.types.path;
      # Replace this with the actual path to your preferred wallpaper
      default = ../../assets/wallpapers/gruvbox.jpg; 
      description = "Path to the background image for swaylock.";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.apollo = {
      programs.swaylock = {
        enable = true;
        package = pkgs.swaylock-effects; # 'effects' version allows for blur/rings
        settings = lib.mkForce {
          image = "${cfg.image}";
          scaling = "fill";
          # Optional: Add some aesthetic rings to match your Gruvbox/Niri setup
          color = "282828";
          ring-color = "fabd2f";
          key-hl-color = "fb4934";
          line-color = "00000000";
          inside-color = "00000000";
          separator-color = "00000000";
        };
      };
    };
  };
}
