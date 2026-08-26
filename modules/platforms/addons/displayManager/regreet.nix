{
  config,
  options,
  lib,
  pkgs,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.displayManager;
  hasServicesRegreet = options ? services.displayManager.regreet;
in
{
  config = lib.mkIf (cfg.manager == "regreet") (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        services.greetd = {
          enable = true;
          settings = {
            default_session = {
              command =
                let
                  regreetLauncher = pkgs.writeShellScript "regreet-launcher" ''
                    # Clean any stored display_name to prevent crashes when monitor setup changes
                    if [ -f /var/lib/regreet/state.toml ]; then
                      ${pkgs.gnused}/bin/sed -i '/display_name/d' /var/lib/regreet/state.toml 2>/dev/null || true
                    fi

                    # Run ReGreet, with a fallback cleanup if it fails
                    if ! ${pkgs.regreet}/bin/regreet; then
                      echo "ReGreet failed. Resetting state and retrying..." >&2
                      rm -rf /var/lib/regreet/state.toml /var/cache/regreet/* 2>/dev/null || true
                      ${pkgs.regreet}/bin/regreet || true
                    fi

                    ${pkgs.sway}/bin/swaymsg exit
                  '';
                  # Build Sway monitor configs from desktop monitor configuration
                  niriMonitors = config.myFeatures.platforms.desktops.niri.monitors or [ ];
                  primaryNiriMonitors = lib.filter (
                    m: m.enable && (m.primary or false || m.focusAtStartup or false)
                  ) niriMonitors;
                  primaryNiriMonitor = if primaryNiriMonitors != [ ] then lib.head primaryNiriMonitors else null;

                  commonResolutions = {
                    "720p" = "1280x720";
                    "1080p" = "1920x1080";
                    "fhd" = "1920x1080";
                    "1440p" = "2560x1440";
                    "2k" = "2560x1440";
                    "qhd" = "2560x1440";
                    "4k" = "3840x2160";
                    "uhd" = "3840x2160";
                  };

                  swayOutputLines = lib.concatMapStringsSep "\n" (
                    m:
                    let
                      allNames = [ m.name ] ++ m.aliases;
                      res =
                        if m.width != null && m.height != null then
                          "${toString m.width}x${toString m.height}"
                        else if m.resolution != null && m.resolution != "auto" then
                          let
                            lower = lib.toLower (toString m.resolution);
                          in
                          commonResolutions.${lower} or (if lib.hasInfix "x" lower then lower else null)
                        else
                          null;
                      modeStr =
                        if res != null then
                          (if m.refresh != null then "${res}@${toString (m.refresh * 1.0)}Hz" else res)
                        else
                          null;
                      posX =
                        if m.x != null then
                          m.x
                        else if m.position != null then
                          m.position.x
                        else
                          null;
                      posY =
                        if m.y != null then
                          m.y
                        else if m.position != null then
                          m.position.y
                        else
                          null;
                      pos = if posX != null && posY != null then "${toString posX} ${toString posY}" else null;
                      ori = lib.toLower (toString m.orientation);
                      transformStr =
                        if ori == "vertical" || ori == "portrait" || ori == "90" then
                          "90"
                        else if ori == "vertical-inverted" || ori == "portrait-inverted" || ori == "270" then
                          "270"
                        else if ori == "inverted" || ori == "180" then
                          "180"
                        else
                          "normal";
                    in
                    lib.concatMapStringsSep "\n" (
                      name:
                      "output \"${name}\" "
                      + (lib.optionalString (modeStr != null) "mode ${modeStr} ")
                      + (lib.optionalString (pos != null) "pos ${pos} ")
                      + (lib.optionalString (transformStr != "normal") "transform ${transformStr} ")
                      + "enable"
                    ) allNames
                  ) (lib.filter (m: m.enable) niriMonitors);

                  targetPrimaryOutput =
                    if cfg.primaryOutput != null then
                      cfg.primaryOutput
                    else if primaryNiriMonitor != null then
                      primaryNiriMonitor.name
                    else
                      null;

                  swayPrimaryFocus =
                    if targetPrimaryOutput != null then
                      ''
                        focus output "${targetPrimaryOutput}"
                        for_window [app_id="regreet"] move to output "${targetPrimaryOutput}"
                      ''
                    else
                      "";

                  # We use sway to launch regreet. Using 'output * enable' ensures fallback works on all hosts
                  swayExtraLines = lib.concatStringsSep "\n" cfg.extraConfig;
                  swayConfig = pkgs.writeText "greetd-sway-config" ''
                    output * enable
                    output * bg #000000 solid_color
                    ${lib.optionalString cfg.syncOutputs swayOutputLines}
                    ${lib.optionalString cfg.syncOutputs swayPrimaryFocus}
                    ${swayExtraLines}
                    exec "${regreetLauncher}"
                  '';
                  greetdSession = pkgs.writeShellScript "greetd-session" ''
                    # Prioritize DRM devices with connected outputs so Sway attaches to active monitor GPUs
                    CONNECTED_CARDS=""
                    OTHER_CARDS=""
                    for card in /sys/class/drm/card[0-9]*; do
                      card_name=$(basename "$card")
                      dev_path="/dev/dri/$card_name"
                      if [ -e "$dev_path" ]; then
                        if grep -q "^connected" "$card"/*/status 2>/dev/null; then
                          CONNECTED_CARDS="''${CONNECTED_CARDS:+$CONNECTED_CARDS:}$dev_path"
                        else
                          OTHER_CARDS="''${OTHER_CARDS:+$OTHER_CARDS:}$dev_path"
                        fi
                      fi
                    done
                    if [ -n "$CONNECTED_CARDS" ]; then
                      export WLR_DRM_DEVICES="''${CONNECTED_CARDS}:''${OTHER_CARDS}"
                    fi

                    export WLR_NO_HARDWARE_CURSORS=1
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
          "d /var/lib/greetd 0750 greeter greeter - -"
          "d /var/lib/regreet 0755 greeter greeter - -"
          "d /var/cache/regreet 0750 greeter greeter - -"
          "Z /var/lib/greetd 0750 greeter greeter - -"
          "Z /var/lib/regreet 0755 greeter greeter - -"
          "Z /var/cache/regreet 0750 greeter greeter - -"
        ];

        # Stylix integration: Disable the official Stylix target to avoid warning about custom default_session command
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

      (
        let
          regreetConfig = {
            enable = true;
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
          // lib.optionalAttrs (config.stylix.enable && config.stylix.fonts.sansSerif.package != null) {
            font = {
              name = config.stylix.fonts.sansSerif.name;
              package = config.stylix.fonts.sansSerif.package;
            };
          }
          //
            lib.optionalAttrs
              (
                config.stylix.enable
                && (config.stylix ? cursor)
                && config.stylix.cursor != null
                && config.stylix.cursor.package != null
              )
              {
                cursorTheme = {
                  name = config.stylix.cursor.name;
                  package = config.stylix.cursor.package;
                };
              }
          //
            lib.optionalAttrs
              (
                config.stylix.enable
                && (config.stylix ? icons)
                && config.stylix.icons != null
                && config.stylix.icons.package != null
              )
              {
                iconTheme = {
                  name =
                    if (config.stylix.polarity == "dark") then config.stylix.icons.dark else config.stylix.icons.light;
                  package = config.stylix.icons.package;
                };
              }
          //
            lib.optionalAttrs (config.stylix.enable && (config.stylix ? image) && config.stylix.image != null)
              {
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
              };
        in
        if hasServicesRegreet then
          { services.displayManager.regreet = regreetConfig; }
        else
          { programs.regreet = regreetConfig; }
      )
    ]
  );
}
