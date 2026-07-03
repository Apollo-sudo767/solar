{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.platforms.styling.gruvboxNiri;
in
{
  options.myFeatures.platforms.styling.gruvboxNiri.enable =
    lib.mkEnableOption "Apollo's Gruvbox Niri Rice";

  config = lib.mkIf cfg.enable {
    myFeatures.platforms = {
      desktops.niri.enable = true;
      addons = {
        # noctalia-shell.enable = false;
        #idle.enable = true;
        #fuzzel.enable = true;
        #swaylock.enable = true;
      };
      styling.themes.gruvbox.enable = true;
      styling.niriKeybinds.enable = true;
    };

    # Simplify the user generation logic
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      programs.niri.settings = {
        prefer-no-csd = true;
        layer-rules = [
          {
            matches = [ { namespace = "noctalia-bar-default"; } ];
            background-effect = {
              blur = true;
              xray = true;
            };
          }
          {
            matches = [ { namespace = "^wallpaper$"; } ];
            place-within-backdrop = true;
          }
          {
            matches = [ { namespace = "^noctalia-wallpaper$"; } ];
            place-within-backdrop = true;
          }
          {
            matches = [ { namespace = "^noctalia-overview$"; } ];
            place-within-backdrop = true;
          }
        ];
        window-rules = [
          {
            matches = [ { app-id = "com.mitchellh.ghostty"; } ];
            background-effect = {
              blur = true;
              xray = true;
            };
            draw-border-with-background = false;
            border.enable = false;
            focus-ring = {
              enable = true;
              width = 2;
              active.color = if config.stylix.enable then "#${config.lib.stylix.colors.base0D}" else "#83a598";
              inactive.color = if config.stylix.enable then "#${config.lib.stylix.colors.base02}" else "#504945";
            };
          }
          {
            matches = [
              { app-id = "^steam_app_"; }
              { app-id = "^gamescope$"; }
            ];
            open-fullscreen = true;
          }
        ];
        layout = {
          background-color = "transparent";
          gaps = 0;
          focus-ring = {
            enable = false;
            width = 0;
            # These only evaluate correctly once Stylix is enabled
            active.color = if config.stylix.enable then "#${config.lib.stylix.colors.base0D}" else "#83a598";
            inactive.color = if config.stylix.enable then "#${config.lib.stylix.colors.base02}" else "#504945";
          };
          border = lib.mkForce {
            enable = false;
            width = 0;
          };
        };
      };
    });
  };
}
