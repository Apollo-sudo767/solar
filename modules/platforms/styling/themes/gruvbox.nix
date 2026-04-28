{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  inherit isTotal;
  cfg = config.myFeatures.platforms.styling.themes.gruvbox;
in
{
  options.myFeatures.platforms.styling.themes.gruvbox.enable = lib.mkEnableOption "Gruvbox Theme";

  config = lib.mkIf cfg.enable {
    myFeatures.platforms.styling.stylix = {
      enable = true;
      scheme = lib.mkDefault (pkgs.base16-schemes + "/share/themes/gruvbox-dark-medium.yaml");
      # Correct Path Literal
      wallpaper = lib.mkDefault ../../../../assets/wallpapers/gruvbox.jpg;
    };
  };
}
