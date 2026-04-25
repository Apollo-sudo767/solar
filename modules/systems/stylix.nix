{ config, lib, pkgs, inputs, isDarwin, ... }:

let
  cfg = config.myFeatures.systems.stylix;
in
{
  # 1. Unconditional imports to avoid evaluation loops
  imports = [
    inputs.stylix-unstable.nixosModules.stylix
    inputs.stylix-unstable.darwinModules.stylix
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

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      
      # Use a simple string check for image path to avoid pkgs.nixos-icons recursion
      image = if (cfg.wallpaper != null) 
              then cfg.wallpaper 
              else pkgs.nixos-icons + "/share/icons/hicolor/48x48/apps/nix-snowflake-white.png";

      base16Scheme = if (cfg.scheme != null) 
                     then cfg.scheme 
                     else "${pkgs.base16-schemes}/share/themes/nord.yaml";

      polarity = "dark";
      
      targets = {
        limine.enable = false;
        # Use the isDarwin flag passed from the loader instead of pkgs.stdenv.isLinux
        plymouth.enable = !isDarwin;
        gnome.enable = !isDarwin;
        
        qt = {
          enable = true;
          # Lazy check: only apply mkForce if we are definitely on Linux
          platform = if !isDarwin then lib.mkForce "qtct" else null;
        };
      };
    };

    # Use lib.optionalAttrs with the isDarwin flag to shield these from macOS
    qt = lib.optionalAttrs (!isDarwin) {
      enable = true;
      platformTheme = lib.mkForce "kde";
      style = lib.mkForce "kvantum";
    };    
  };
}
