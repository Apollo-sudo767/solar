# modules/platforms/styling/skyNoctalia.nix
# ============================================================================
# Sky Noctalia v5 Shell Rice
# ============================================================================
# Configures the Noctalia v5 Wayland shell bar, capsule groups, launcher,
# notification center, session menu, and desktop widgets for the Sky flavor.
{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.platforms.styling.skyNoctalia;
  inherit (config.myFeatures.core.system.users) usernames;
in
{
  options.myFeatures.platforms.styling.skyNoctalia.enable =
    lib.mkEnableOption "Apollo's Sky Noctalia v5 Rice";

  config = lib.mkIf cfg.enable {
    myFeatures.platforms.addons.noctalia-v5.enable = true;

    home-manager.users = lib.genAttrs usernames (_name: {
      programs.noctalia = {
        settings = {
          bar = {
            backgroundOpacity = 0.6;
            barType = "simple";
            capsuleColorKey = "none";
            capsuleOpacity = 0.6;
            contentPadding = 2;
            density = "default";
            displayMode = "always_visible";
            enable = true;
            enableExclusionZoneInset = true;
            fontScale = 1;
            frameRadius = 12;
            frameThickness = 8;
            height = 36;
            hideOnOverview = false;
            marginHorizontal = 4;
            marginVertical = 4;
            order = [
              "default"
            ];
            outerCorners = true;
            position = "bottom";
            showCapsule = true;
            showOutline = false;
            useSeparateOpacity = false;
            widgetSpacing = 6;

            default = {
              contact_shadow = true;
              margin_edge = 0;
              margin_ends = 0;
              position = "bottom";
              shadow = false;

              start = [
                "launcher"
                "workspaces"
              ];

              center = [
                "group:media_group"
              ];

              end = [
                "group:hardware_group"
                "tray"
                "notifications"
                "clock"
                "control-center"
              ];

              capsule_group = [
                {
                  fill = "surface_variant";
                  id = "media_group";
                  members = [
                    "media"
                  ];
                  opacity = 0.6;
                  padding = 6.0;
                }
                {
                  fill = "surface_variant";
                  id = "hardware_group";
                  members = [
                    "network"
                    "bluetooth"
                    "volume"
                    "brightness"
                    "battery"
                  ];
                  opacity = 0.6;
                  padding = 6.0;
                }
              ];
            };

            widgets.enabled = false;
          };

          dock.enabled = false;

          hot_corners = {
            enabled = false;
            delay_ms = 0;
            top_left = {
              action = "none";
              command = "";
            };
            top_right = {
              action = "none";
              command = "";
            };
            bottom_left = {
              action = "none";
              command = "";
            };
            bottom_right = {
              action = "none";
              command = "";
            };
          };

          idle = {
            behavior_order = [
              "lock"
              "screen-off"
              "lock-and-suspend"
            ];
            behavior = {
              lock = {
                action = "lock";
                enabled = true;
                timeout = 600;
              };
              lock-and-suspend = {
                action = "lock_and_suspend";
                enabled = true;
                timeout = 900;
              };
              screen-off = {
                action = "screen_off";
                enabled = true;
                timeout = 660;
              };
            };
          };

          lockscreen = {
            blurred_desktop = true;
            blur_intensity = 0.62;
          };

          shell = {
            niri_overview_type_to_launch_enabled = true;
            polkit_agent = true;
            panel.transparency_mode = "glass";
          };

          theme = {
            source = if config.stylix.enable then "custom" else "wallpaper";
            custom_palette = if config.stylix.enable then "stylix" else null;
            wallpaper_scheme = "m3-tonal-spot";
          };

          weather = {
            unit = "fahrenheit";
          };

          wallpaper = {
            directory = ../../../assets/wallpapers;
            transition = [
              "disc"
              "fade"
              "honeycomb"
              "stripes"
              "wipe"
              "zoom"
            ];
            transition_on_startup = true;

            default.path =
              if config.stylix.enable then config.stylix.image else ../../../assets/wallpapers/space.png;
            last.path =
              if config.stylix.enable then config.stylix.image else ../../../assets/wallpapers/space.png;

            monitors = { };
          };
        };
      };
    });
  };
}
