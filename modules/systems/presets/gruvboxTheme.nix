{ config, lib, ... }:

{
  options.myFeatures.systems.theme.gruvbox = {
    wallpaper = lib.mkOption {
      type = lib.types.path;
      default = ../../../assets/wallpapers/gruvbox.jpg;
    };
    # You can add shared colors here for swaylock to pick up
    accent = lib.mkOption { type = lib.types.str; default = "d65d0e"; };
    highlight = lib.mkOption { type = lib.types.str; default = "fabd2f"; };
  };
}
