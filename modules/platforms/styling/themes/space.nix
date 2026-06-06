{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.platforms.styling.themes.space;
in
{
  options.myFeatures.platforms.styling.themes.space.enable =
    lib.mkEnableOption "Space Theme Stylix Settings";

  config = lib.mkIf cfg.enable {
    myFeatures.platforms.styling.stylix = {
      enable = true;
      wallpaper = lib.mkDefault ../../../../assets/wallpapers/space.png;
    };
  };
}
