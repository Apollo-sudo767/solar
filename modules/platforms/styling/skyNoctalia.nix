{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.styling.skyNoctalia;
  inherit (config.myFeatures.core.system.users) usernames;
  iconFile = ../../../assets/icons/Apollo.jpg;
in
{
  options.myFeatures.platforms.styling.skyNoctalia.enable =
    lib.mkEnableOption "Apollo's Sky Noctalia v5 Rice";

  config = lib.mkIf cfg.enable {
    myFeatures.platforms.addons.noctalia-v5.enable = true;

    home-manager.users = lib.genAttrs usernames (_name: {
      programs.noctalia = {
        settings = {
          # v5 Specific Configuration - Matched EXACTLY to ~/.config/noctalia/config.toml
          appLauncher = {
            iconMode = "tabler";
            position = "center";
            showCategories = true;
            sortByMostUsed = true;
          };

          bar = {
            backgroundOpacity = 1.0;
            barType = "simple";
            capsuleColorKey = "none";
            capsuleOpacity = 1.0;
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
              "widgets"
            ];
            outerCorners = true;
            position = "bottom";
            showCapsule = true;
            showOutline = false;
            useSeparateOpacity = false;
            widgetSpacing = 6;

            default = {
              center = [ "group:g1" ];
              contact_shadow = true;
              end = [
                "tray"
                "notifications"
                "clock"
                "volume"
                "brightness"
                "battery"
              ];
              margin_edge = 0;
              margin_ends = 0;
              position = "bottom";
              shadow = false;
              start = [
                "group:g2"
                "launcher"
                "workspaces"
              ];

              capsule_group = [
                {
                  fill = "surface_variant";
                  id = "g1";
                  members = [
                    "control-center"
                    "media"
                    "session"
                  ];
                  opacity = 1.0;
                  padding = 6.0;
                }
                {
                  fill = "surface_variant";
                  id = "g2";
                  members = [
                    "network"
                    "bluetooth"
                  ];
                  opacity = 1.0;
                  padding = 6.0;
                }
              ];
            };

            widgets.enabled = false;
          };

          colors = {
            mBackground = "#050a18";
            mOnBackground = "#abb2bf";
            mOnPrimary = "#050a18";
            mOnSecondary = "#050a18";
            mOnSurface = "#abb2bf";
            mOutline = "#101f3b";
            mPrimary = "#2471a3";
            mSecondary = "#ff9f43";
            mSurface = "#050a18";
          };

          controlCenter = {
            position = "close_to_bar_button";
            shortcuts = {
              left = [
                { id = "Network"; }
                { id = "Bluetooth"; }
                { id = "WallpaperSelector"; }
              ];
              right = [
                { id = "Notifications"; }
                { id = "PowerProfile"; }
                { id = "KeepAwake"; }
              ];
            };
          };

          dock.enabled = false;

          general = {
            animationSpeed = 1;
            avatarImage = iconFile;
            enableBlurBehind = false;
            enableShadows = true;
            radiusRatio = 1;
            screenRadiusRatio = 1;
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
            wallpaper_blur_intensity = 0.61999998614192009;
          };

          shell = {
            niri_overview_type_to_launch_enabled = true;
            polkit_agent = true;
            panel.transparency_mode = "solid";
          };

          theme = {
            community_palette = "m3-content";
            source = "wallpaper";
            wallpaper_scheme = "Noctalia";
          };

          wallpaper = {
            directory = pkgs.runCommand "noctalia-sky-wallpapers" { } ''
              mkdir -p $out
              cp ${../../../assets/wallpapers/space.png} $out/space.png
            '';
            transition = [
              "disc"
              "fade"
              "honeycomb"
              "stripes"
              "wipe"
              "zoom"
            ];
            transition_on_startup = true;

            default.path = ../../../assets/wallpapers/space.png;
            last.path = ../../../assets/wallpapers/space.png;

            monitors = {
              DP-1.path = ../../../assets/wallpapers/space.png;
              DP-2.path = ../../../assets/wallpapers/space.png;
            };
          };
        };
      };
    });
  };
}
