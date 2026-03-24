{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.systems.stylix.forest;
in
{
  options.myFeatures.systems.stylix.forest = {
    enable = lib.mkEnableOption "Apply Gruvbox Theme";
  };

  config = lib.mkIf cfg.enable {
    # This automatically turns on the main styling logic!
    myFeatures.systems.stylix = {
      enable = true; 
      wallpaper = ../../../assets/wallpapers/forest.jpg;
    };
  };
}
