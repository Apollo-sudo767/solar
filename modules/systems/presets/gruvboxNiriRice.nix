{ config, lib, pkgs, isStable, inputs, ... }:

let
  cfg = config.myFeatures.systems.presets.gruvboxNiri;
  # Determine stateVersion based on the host's channel
  dynamicVersion = if isStable then "25.11" else "26.05";
in
{
  options.myFeatures.systems.presets.gruvboxNiri.enable = lib.mkEnableOption "Apollo's Gruvbox Niri Rice";

  config = lib.mkIf cfg.enable {
    myFeatures.systems = {
      niri.enable = true;
      waybar.enable = true;
      swaybg.enable = true;
      idle.enable = true;
      stylix = {
        enable = true;
        gruvbox.enable = true;
      };
      presets.niriKeybinds.enable = true;
    };

    home-manager.users = let
      # Specifically filter the usernames list to prevent option keys from leaking
      userList = lib.filter (n: n != "enable" && n != "usernames") config.myFeatures.core.users.usernames;
    in lib.genAttrs userList (name: {

      home.stateVersion = dynamicVersion;

      programs.niri.settings = {
        layout = {
          gaps = 8;
          focus-ring = {
            enable = true;
            width = 2;
            active.color = "#${config.lib.stylix.colors.base0D}";
            inactive.color = "#${config.lib.stylix.colors.base02}";
          };
        };

      };

      programs.waybar.style = lib.mkForce ''
        @define-color base00 #${config.lib.stylix.colors.base00};
        @define-color base0D #${config.lib.stylix.colors.base0D};
        window#waybar {
          background: @base00;
          border-bottom: 2px solid @base0D;
          font-family: "JetBrainsMono Nerd Font";
        }
      '';
    });
  };
}
