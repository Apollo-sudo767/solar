{
  config,
  lib,
  pkgs,
  isTotal,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.platforms.styling.themes.forest;
in
{
  options.myFeatures.platforms.styling.themes.forest.enable = lib.mkEnableOption "Forest Theme";

  config = lib.mkIf cfg.enable {
    myFeatures.platforms.styling.stylix = {
      enable = true;
      # Using mkDefault allows the base engine fallbacks to stay at lower priority
      scheme = lib.mkDefault (pkgs.base16-schemes + "/share/themes/nord.yaml");
      wallpaper = lib.mkDefault ../../../../assets/wallpapers/forest.jpg;
    };
  };
}
