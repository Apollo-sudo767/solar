{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.systems.styling;
in
{
  imports = [ inputs.stylix-unstable.nixosModules.stylix ];

  options.myFeatures.systems.gruvboxStyle = {
    enable = lib.mkEnableOption "Universal Gruvbox Styling";
    
    # Simplified: No more enums, just a standard toggle or specific name
    gruvboxStyle = lib.mkOption {
      type = lib.types.str;
      default = "dark-medium";
      description = "The Gruvbox flavor to apply (e.g., dark-medium).";
    };

    wallpaper = lib.mkOption {
      type = lib.types.path;
      default = ../../assets/wallpapers/gruvbox.jpg;
      description = "The wallpaper to base the theme on.";
    };
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      image = cfg.wallpaper;
      
      # We still point to the base16-schemes but without the rigid list
      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-${cfg.gruvboxStyle}.yaml";
      
      polarity = "dark"; # Assuming Apollo stays in the shadows

      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
        sizes = {
          terminal = 12;
          applications = 11;
        };
      };

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 24;
      };
    };
  };
}
