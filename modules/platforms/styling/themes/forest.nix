{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  inherit isTotal;
  cfg = config.myFeatures.platforms.styling.themes.forest;
in
{
  options.myFeatures.platforms.styling.themes.forest.enable = lib.mkEnableOption "Forest Theme";

  config = lib.mkIf cfg.enable {
    myFeatures.platforms.styling.stylix = {
      enable = true;
      # Removed fixed scheme to allow Stylix auto-generation
      wallpaper = lib.mkDefault ../../../../assets/wallpapers/forest.jpg;
    };
  };
}
