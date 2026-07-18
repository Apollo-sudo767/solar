{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.platforms.styling.skyNiri;
in
{
  options.myFeatures.platforms.styling.skyNiri.enable =
    lib.mkEnableOption "Apollo's Sky Niri Rice (Centralized)";

  config = lib.mkIf cfg.enable {
    myFeatures.platforms = {
      # Enable the Sky Theme (Stylix settings)
      styling.themes.sky.enable = true;

      # Enable all the addons for this rice
      addons = {
        # swayosd.enable = true;
        # fuzzel.enable = true;
        # swaylock.enable = true;
        # swaybg.enable = lib.mkForce false;
      };

      # Enable Niri and Keybinds
      desktops.niri.enable = true;
      styling.niriKeybinds.enable = true;

      # Use the NEW Noctalia v5 Rice instead of defaults
      styling.skyNoctalia.enable = true;
    };

    # Niri-specific aesthetic tweaks for the "Sky" look
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
        window-rules = lib.mkForce [
          {
            geometry-corner-radius = {
              top-left = 10.0;
              top-right = 10.0;
              bottom-left = 10.0;
              bottom-right = 10.0;
            };
            clip-to-geometry = true;
            focus-ring.enable = false;
          }
          {
            matches = [ { app-id = "firefox"; } ];
            border.enable = false;
            focus-ring.enable = false;
          }
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
          {
            matches = [
              {
                app-id = "^steam$";
                title = "^notificationtoasts_[0-9]+_desktop$";
              }
            ];
            default-floating-position = {
              x = 16;
              y = 16;
              relative-to = "bottom-right";
            };
            open-floating = true;
            open-focused = false;
          }
        ];
        layout = lib.mkForce {
          background-color = "transparent";
          gaps = 8;
          focus-ring = {
            enable = false;
            width = 0;
          };
          border = {
            enable = true;
            width = 2;
            active.color = if config.stylix.enable then "#${config.lib.stylix.colors.base0D}" else "#83a598";
            inactive.color = if config.stylix.enable then "#${config.lib.stylix.colors.base02}" else "#504945";
          };
        };
      };
    });

  };
}
