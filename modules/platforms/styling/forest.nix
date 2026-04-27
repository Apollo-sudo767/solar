{
  config,
  lib,
  pkgs,
  isTotal,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.platforms.styling.forest;
in
{
  options.myFeatures.platforms.styling.forest.enable = lib.mkEnableOption "Forest Theme";

  config = lib.mkIf cfg.enable {
    myFeatures.platforms.addons.stylix = {
      enable = true;
      # Using mkDefault allows the base engine fallbacks to stay at lower priority
      scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/nord.yaml";
      wallpaper = lib.mkDefault ../../../assets/wallpapers/forest.jpg;
    };
  };
}
