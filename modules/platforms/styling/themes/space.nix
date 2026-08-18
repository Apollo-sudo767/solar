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
      scheme = {
        base00 = "0f1419";
        base01 = "131721";
        base02 = "1e2430";
        base03 = "242936";
        base04 = "707a8c";
        base05 = "b3b1ad";
        base06 = "e6e1cf";
        base07 = "f2eede";
        base08 = "f29668";
        base09 = "ff8f40";
        base0A = "e6b450";
        base0B = "c2d94c";
        base0C = "95e6cb";
        base0D = "59c2ff";
        base0E = "d4bfff";
        base0F = "e6b450";
      };
      wallpaper = lib.mkDefault ../../../../assets/wallpapers/space.png;
    };
  };
}
