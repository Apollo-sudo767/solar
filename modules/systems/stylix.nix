{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.systems.stylix;
in
{
  # 1. Import the NixOS module which handles system + home-manager styling
  imports = [ inputs.stylix-unstable.nixosModules.stylix ];

  options.myFeatures.systems.stylix = {
    enable = lib.mkEnableOption "Universal Stylix Styling";
    
    # Internal options populated by your presets (forest.nix, gruvbox.nix)
    scheme = lib.mkOption { 
      type = lib.types.nullOr lib.types.str; 
      default = null; 
    };

    wallpaper = lib.mkOption { 
      type = lib.types.nullOr lib.types.path;
      default = null; 
    };
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      
      # FALLBACK LOGIC: 
      # If a preset provides a wallpaper, use it. 
      # Otherwise, use a safe absolute path from the Nix store to prevent crashes.
      image = if (cfg.wallpaper != null) 
              then cfg.wallpaper 
              else pkgs.nixos-icons + "/share/icons/hicolor/48x48/apps/nix-snowflake-white.png";

      # If a preset provides a scheme, use it. 
      # Otherwise, default to Nord which matches your forest aesthetic.
      base16Scheme = if (cfg.scheme != null) 
                     then cfg.scheme 
                     else "${pkgs.base16-schemes}/share/themes/nord.yaml";
      
      polarity = "dark";
      
      targets = {
        limine.enable = false;
        plymouth = {
          enable = true;
          logoAnimated = true;
          logo = "${pkgs.nixos-icons}/share/icons/hicolor/48x48/apps/nix-snowflake-white.png";          
        };
      };
    };

    # We do NOT use home-manager.sharedModules here. 
    # The NixOS module automatically injects these settings into all HM users.
  };
}
