{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.systems.stylix.forest;
in
{
  options.myFeatures.systems.stylix.forest.enable = lib.mkEnableOption "Forest Theme";

  config = lib.mkIf cfg.enable {
    myFeatures.systems.stylix = {
      enable = true;
      # Using mkDefault allows the base engine fallbacks to stay at lower priority
      scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/nord.yaml";
      wallpaper = lib.mkDefault ../../../assets/wallpapers/forest.jpg;
    };
  };
}
