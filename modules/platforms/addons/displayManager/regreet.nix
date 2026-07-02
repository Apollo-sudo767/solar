{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.displayManager;
in
{
  config = lib.mkIf (cfg.manager == "regreet") (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        programs.regreet.enable = true;
        services.greetd = {
          enable = true;
          settings = {
            default_session = {
              command =
                let
                  # We use sway to launch regreet. Using 'output *' ensures it works on all hosts
                  # regardless of their monitor names (DP-1 vs eDP-1).
                  swayConfig = pkgs.writeText "greetd-sway-config" ''
                    output * bg #000000 solid_color
                    exec "${pkgs.regreet}/bin/regreet; ${pkgs.sway}/bin/swaymsg exit"
                  '';
                  greetdSession = pkgs.writeShellScript "greetd-session" ''
                    export WLR_NO_HARDWARE_CURSORS=1
                    export WLR_RENDERER=pixman
                    export WLR_DRM_NO_ATOMIC=1
                    export WLR_DRM_NO_MODIFIERS=1
                    export __GL_GSYNC_ALLOWED=0
                    export __GL_VRR_ALLOWED=0
                    export GTK_USE_PORTAL=0
                    exec ${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway --config ${swayConfig} --unsupported-gpu
                  '';
                in
                "${greetdSession}";
              user = "greeter";
            };
          };
        };

        # Ensure correct permissions for the greeter user on persistent directories
        systemd.tmpfiles.rules = [
          "d /var/lib/greetd 0750 greeter greetd - -"
          "d /var/lib/regreet 0755 greeter greeter - -"
          "d /var/cache/regreet 0750 greeter greetd - -"
          "Z /var/lib/greetd 0750 greeter greetd - -"
          "Z /var/lib/regreet 0755 greeter greeter - -"
          "Z /var/cache/regreet 0750 greeter greetd - -"
        ];

        # Stylix integration: Disable the official Stylix target to avoid warning about custom default_session command,
        # and manually configure programs.regreet with Stylix values.
        stylix.targets.regreet.enable = false;

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              directories = [
                "/var/lib/greetd"
                "/var/lib/regreet"
                "/var/cache/regreet"
              ];
            };
      })

      {
        programs.regreet = lib.mkIf (!isDarwin && config.stylix.enable) (lib.mkMerge [
          {
            theme = {
              package = pkgs.adw-gtk3;
              name = "adw-gtk3";
            };
            settings.GTK.application_prefer_dark_theme = config.stylix.polarity == "dark";
            extraCss =
              let
                c = config.lib.stylix.colors.withHashtag;
              in
              pkgs.writeText "regreet-stylix.css" ''
                @define-color accent_color ${c.base0D};
                @define-color accent_bg_color ${c.base0D};
                @define-color accent_fg_color ${c.base00};
                @define-color destructive_color ${c.base08};
                @define-color destructive_bg_color ${c.base08};
                @define-color destructive_fg_color ${c.base00};
                @define-color success_color ${c.base0B};
                @define-color success_bg_color ${c.base0B};
                @define-color success_fg_color ${c.base00};
                @define-color warning_color ${c.base0E};
                @define-color warning_bg_color ${c.base0E};
                @define-color warning_fg_color ${c.base00};
                @define-color error_color ${c.base08};
                @define-color error_bg_color ${c.base08};
                @define-color error_fg_color ${c.base00};
                @define-color window_bg_color ${c.base00};
                @define-color window_fg_color ${c.base05};
                @define-color view_bg_color ${c.base00};
                @define-color view_fg_color ${c.base05};
                @define-color headerbar_bg_color ${c.base01};
                @define-color headerbar_fg_color ${c.base05};
                @define-color headerbar_border_color rgba(${config.lib.stylix.colors.base01-dec-r}, ${config.lib.stylix.colors.base01-dec-g}, ${config.lib.stylix.colors.base01-dec-b}, 0.7);
                @define-color headerbar_backdrop_color @window_bg_color;
                @define-color headerbar_shade_color rgba(0, 0, 0, 0.07);
                @define-color headerbar_darker_shade_color rgba(0, 0, 0, 0.07);
                @define-color sidebar_bg_color ${c.base01};
                @define-color sidebar_fg_color ${c.base05};
                @define-color sidebar_backdrop_color @window_bg_color;
                @define-color sidebar_shade_color rgba(0, 0, 0, 0.07);
                @define-color secondary_sidebar_bg_color @sidebar_bg_color;
                @define-color secondary_sidebar_fg_color @sidebar_fg_color;
                @define-color secondary_sidebar_backdrop_color @sidebar_backdrop_color;
                @define-color secondary_sidebar_shade_color @sidebar_shade_color;
                @define-color card_bg_color ${c.base01};
                @define-color card_fg_color ${c.base05};
                @define-color card_shade_color rgba(0, 0, 0, 0.07);
                @define-color dialog_bg_color ${c.base01};
                @define-color dialog_fg_color ${c.base05};
                @define-color popover_bg_color ${c.base01};
                @define-color popover_fg_color ${c.base05};
                @define-color popover_shade_color rgba(0, 0, 0, 0.07);
                @define-color shade_color rgba(0, 0, 0, 0.07);
                @define-color scrollbar_outline_color ${c.base02};
                @define-color blue_1 ${c.base0D};
                @define-color blue_2 ${c.base0D};
                @define-color blue_3 ${c.base0D};
                @define-color blue_4 ${c.base0D};
                @define-color blue_5 ${c.base0D};
                @define-color green_1 ${c.base0B};
                @define-color green_2 ${c.base0B};
                @define-color green_3 ${c.base0B};
                @define-color green_4 ${c.base0B};
                @define-color green_5 ${c.base0B};
                @define-color yellow_1 ${c.base0A};
                @define-color yellow_2 ${c.base0A};
                @define-color yellow_3 ${c.base0A};
                @define-color yellow_4 ${c.base0A};
                @define-color yellow_5 ${c.base0A};
                @define-color orange_1 ${c.base09};
                @define-color orange_2 ${c.base09};
                @define-color orange_3 ${c.base09};
                @define-color orange_4 ${c.base09};
                @define-color orange_5 ${c.base09};
                @define-color red_1 ${c.base08};
                @define-color red_2 ${c.base08};
                @define-color red_3 ${c.base08};
                @define-color red_4 ${c.base08};
                @define-color red_5 ${c.base08};
                @define-color purple_1 ${c.base0E};
                @define-color purple_2 ${c.base0E};
                @define-color purple_3 ${c.base0E};
                @define-color purple_4 ${c.base0E};
                @define-color purple_5 ${c.base0E};
                @define-color brown_1 ${c.base0F};
                @define-color brown_2 ${c.base0F};
                @define-color brown_3 ${c.base0F};
                @define-color brown_4 ${c.base0F};
                @define-color brown_5 ${c.base0F};
                @define-color light_1 ${c.base05};
                @define-color light_2 ${c.base05};
                @define-color light_3 ${c.base05};
                @define-color light_4 ${c.base05};
                @define-color light_5 ${c.base05};
                @define-color dark_1 ${c.base05};
                @define-color dark_2 ${c.base05};
                @define-color dark_3 ${c.base05};
                @define-color dark_4 ${c.base05};
                @define-color dark_5 ${c.base05};
              '';
          }
          (lib.optionalAttrs (config.stylix.fonts.sansSerif.package != null) {
            font = {
              name = config.stylix.fonts.sansSerif.name;
              package = config.stylix.fonts.sansSerif.package;
            };
          })
          (lib.optionalAttrs (config.stylix.cursor.package != null) {
            cursorTheme = {
              name = config.stylix.cursor.name;
              package = config.stylix.cursor.package;
            };
          })
          (lib.optionalAttrs (config.stylix.icons.package != null) {
            iconTheme = {
              name = if (config.stylix.polarity == "dark") then config.stylix.icons.dark else config.stylix.icons.light;
              package = config.stylix.icons.package;
            };
          })
          (lib.optionalAttrs (config.stylix.image != null) {
            settings.background = {
              path = config.stylix.image;
              fit =
                if config.stylix.imageScalingMode == "fill" then
                  "Cover"
                else if config.stylix.imageScalingMode == "fit" then
                  "Contain"
                else if config.stylix.imageScalingMode == "stretch" then
                  "Fill"
                else
                  null;
            };
          })
        ]);
      }
    ]
  );
}
