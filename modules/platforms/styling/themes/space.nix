{
  config,
  lib,
  pkgs,
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
      scheme = lib.mkDefault (pkgs.base16-schemes + "/share/themes/ayu-dark.yaml");
      wallpaper = lib.mkDefault ../../../../assets/wallpapers/space.png;
    };
  };
}
