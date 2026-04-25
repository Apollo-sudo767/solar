{
  config,
  lib,
  pkgs,
  isTotal,
  isDarwin,
  ...
}:

{
  options.myFeatures.systems.stylix.gruvbox.enable = lib.mkEnableOption "Gruvbox Theme";

  config = lib.mkIf config.myFeatures.systems.stylix.gruvbox.enable {
    myFeatures.systems.stylix = {
      enable = true;
      scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
      wallpaper = ../../../assets/wallpapers/gruvbox.jpg;
    };
  };
}
