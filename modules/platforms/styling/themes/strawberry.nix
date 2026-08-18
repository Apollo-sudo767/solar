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
      polarity = "light";
      scheme = {
        base00 = "fff5f7"; # Soft light strawberry cream background
        base01 = "ffe3e8"; # Lighter strawberry panel background
        base02 = "ffd1da"; # Active selection / hover background
        base03 = "b57c8a"; # Muted text / comments
        base04 = "8c4d5c"; # Dark muted text
        base05 = "3a101c"; # Primary deep berry dark text
        base06 = "1f050d"; # Darker text / titles
        base07 = "140208"; # Deepest contrast text
        base08 = "d90429"; # Ripe strawberry red
        base09 = "ff5964"; # Warm coral pink
        base0A = "e68a00"; # Warm golden seed accent
        base0B = "2b9348"; # Fresh leaf green
        base0C = "00a896"; # Mint teal
        base0D = "c1121f"; # Deep crimson accent
        base0E = "b5179e"; # Sweet berry violet
        base0F = "800f2e"; # Ruby jam accent
      };
      wallpaper = lib.mkDefault ../../../../assets/wallpapers/strawberry.jpg;
    };
  };
}
