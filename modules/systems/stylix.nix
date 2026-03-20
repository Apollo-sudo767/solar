{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.systems.stylix;
in
{
    imports = [ inputs.stylix.nixosModules.stylix ];
    options.myFeatures.systems.styling = {
    enable = lib.mkEnableOption "Universal Stylix Styling";
    
    # Internal options populated by presets
    scheme = lib.mkOption { type = lib.types.str; default = ""; };
    wallpaper = lib.mkOption { type = lib.types.path; default = ../../assets/wallpapers/default.png; };
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      image = cfg.wallpaper;
      base16Scheme = cfg.scheme;
      polarity = "dark";
      # ... (Keep your font and cursor settings here from the previous refactor)
    };
  };
}
