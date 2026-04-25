{ config, lib, pkgs, inputs, isDarwin, ... }:

let
  cfg = config.myFeatures.systems.stylix or { enable = false; };
in
{
  imports = [
    (if isDarwin then inputs.stylix-unstable.darwinModules.stylix else inputs.stylix-unstable.nixosModules.stylix)
  ];
    
  options.myFeatures.systems.stylix = {
    enable = lib.mkEnableOption "Universal Stylix Styling";
    scheme = lib.mkOption { 
      type = lib.types.nullOr lib.types.str; 
      default = null; 
    };
    wallpaper = lib.mkOption { 
      type = lib.types.nullOr lib.types.path;
      default = null; 
    };
  };

  config = lib.mkIf (cfg.enable or false) (lib.mkMerge [
    # 1. Global Stylix Config (Safe for both)
    {
      stylix = {
        enable = true;
        image = if (cfg.wallpaper != null) 
                then cfg.wallpaper 
                else pkgs.nixos-icons + "/share/icons/hicolor/48x48/apps/nix-snowflake-white.png";

        base16Scheme = if (cfg.scheme != null) 
                       then cfg.scheme 
                       else "${pkgs.base16-schemes}/share/themes/nord.yaml";

        polarity = "dark";
        
        # Shield ALL targets that are NixOS-specific
        targets = {
          # Common targets (e.g., helix, neovim) can go here
        } // lib.optionalAttrs (!isDarwin) {
          limine.enable = false; # Moved inside the shield
          plymouth.enable = true;
          gnome.enable = true;
          qt.enable = true;
        };
      };
    }

    # 2. Linux-only QT System-wide engine
    (lib.optionalAttrs (!isDarwin) {
      qt = {
        enable = true;
        platformTheme = lib.mkForce "kde";
        style = lib.mkForce "kvantum";
      };    
    })
  ]);
}
