{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.systems.stylix;
in
{
    imports = [ inputs.stylix-unstable.nixosModules.stylix ];
    options.myFeatures.systems.stylix = {
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
      targets = {
        limine.enable = false;
        plymouth = {
          enable = true;
          logoAnimated = true;
          logo = "${pkgs.nixos-icons}/share/icons/hicolor/48x48/apps/nix-snowflake-white.png";          
        };
      };
    };
  };
}
