{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  inherit isTotal;
  cfg = config.myFeatures.platforms.styling.themes.sky;
in
{
  options.myFeatures.platforms.styling.themes.sky.enable = lib.mkEnableOption "Sky Theme";

  config = lib.mkIf cfg.enable {
    myFeatures.platforms.styling.stylix = {
      enable = true;
      wallpaper = lib.mkDefault ../../../../assets/wallpapers/space.png;

      scheme = {
        base00 = "050a18";
        base01 = "0b1528";
        base02 = "101f3b";
        base03 = "172e54";
        base04 = "61afef";
        base05 = "abb2bf";
        base06 = "c8ccd4";
        base07 = "e06c75";

        base08 = "e67e22";
        base09 = "ff9f43";
        base0A = "f1c40f";
        base0B = "2ecc71";
        base0C = "1abc9c";
        base0D = "2471a3";
        base0E = "9b59b6";
        base0F = "d35400";
      };
    };
  };
}
