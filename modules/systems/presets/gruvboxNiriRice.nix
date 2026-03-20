{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.systems.presets.gruvboxNiri;
in
{

  imports = [
    ../../niri.nix
    ../presets/niriKeybinds.nix
  ]
  options.myFeatures.systems.presets.gruvboxNiri.enable = lib.mkEnableOption "Apollo's Gruvbox Niri Rice";

  config = lib.mkIf cfg.enable {
    # 1. Trigger the underlying Systems
    myFeatures.systems = {
      niri.enable = true;
      waybar.enable = true;
      stylix = {
        enable = true;
        rice = "gruvbox";
      };
    };

    # 2. Rice-Specific Niri Overrides (Parity with Phanes desktop.nix)
    home-manager.users = lib.mapAttrs (name: _: {
      programs.niri.settings = {
        layout = {
          gaps = 8;
          focus-ring = {
            enable = true;
            width = 2;
            # These pull directly from the Stylix Gruvbox palette
            active.color = "#${config.lib.stylix.colors.base0D}"; 
            inactive.color = "#${config.lib.stylix.colors.base02}";
          };
        };
        
        # Ensure the Gruvbox wallpaper is set via swww or similar
        spawn-at-startup = [
          { command = [ "${pkgs.swww}/bin/swww" "img" "${../../assets/wallpapers/gruvbox.jpg}" ]; }
        ];
      };

      # 3. Rice-Specific Waybar Styling
      programs.waybar.style = lib.mkForce ''
        @define-color base00 #${config.lib.stylix.colors.base00};
        @define-color base0D #${config.lib.stylix.colors.base0D};
        window#waybar {
          background: @base00;
          border-bottom: 2px solid @base0D;
          font-family: "JetBrainsMono Nerd Font";
        }
      '';
    }) config.myFeatures.users;
  };
}
