{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.systems.styling.gruvbox;
in
{
  options.myFeatures.systems.styling.gruvbox = {
    enable = lib.mkEnableOption "Apply Gruvbox Theme";
  };

  config = lib.mkIf cfg.enable {
    # This automatically turns on the main styling logic!
    myFeatures.systems.styling = {
      enable = true; 
      scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
      wallpaper = ../../../assets/wallpapers/gruvbox.jpg;
    };
  };
}
