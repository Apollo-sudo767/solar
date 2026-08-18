{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  inherit isTotal;
  cfg = config.myFeatures.platforms.styling.themes.strawberry;
in
{
  options.myFeatures.platforms.styling.themes.strawberry.enable =
    lib.mkEnableOption "Strawberry Theme";

  config = lib.mkIf cfg.enable {
    myFeatures.platforms.styling.stylix = {
      enable = true;
      scheme = {
        base00 = "1f0d13"; # Deep berry dark background
        base01 = "2d141d"; # Lighter berry background
        base02 = "421d2a"; # Selection background / surface
        base03 = "6e3447"; # Comments / muted text
        base04 = "c28695"; # Soft pinkish grey
        base05 = "fce8ec"; # Crisp cream text
        base06 = "ffffff"; # Bright highlight
        base07 = "fff0f3"; # Light blush
        base08 = "ff3b60"; # Ripe strawberry red
        base09 = "ff6b8b"; # Coral pink
        base0A = "ffb3c1"; # Pastel seed yellow-pink
        base0B = "4eb87b"; # Fresh leaf green
        base0C = "5bc0be"; # Mint accent
        base0D = "e63946"; # Deep crimson accent
        base0E = "c71585"; # Raspberry magenta
        base0F = "80092d"; # Ruby jam accent
      };
      wallpaper = lib.mkDefault ../../../../assets/wallpapers/strawberry.jpg;
    };
  };
}
