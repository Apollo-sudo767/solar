{
  config,
  lib,
  pkgs,
  isTotal,
  isDarwin,
  ...
}:

{
  options.myFeatures.platforms.styling.gruvbox.enable = lib.mkEnableOption "Gruvbox Theme";

  config = lib.mkIf config.myFeatures.platforms.styling.gruvbox.enable {
    myFeatures.platforms.addons.stylix = {
      enable = true;
      scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
      # Correct Path Literal
      wallpaper = ../../../assets/wallpapers/gruvbox.jpg;
    };
  };
}
