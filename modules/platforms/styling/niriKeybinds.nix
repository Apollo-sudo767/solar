{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.platforms.styling.niriKeybinds;

  browsers = config.myFeatures.programs.browsers;
  firefoxCfg = browsers.firefox;
  zenCfg = browsers.zen;
  chromeCfg = browsers.chrome;

  defaultBrowserCmd =
    if (firefoxCfg.enable || firefoxCfg.nightly.enable) && firefoxCfg.default then
      (if firefoxCfg.nightly.enable then "firefox-nightly" else "firefox")
    else if zenCfg.enable && zenCfg.default then
      "zen"
    else if chromeCfg.enable && chromeCfg.default then
      (if chromeCfg.googleChrome.enable then "google-chrome" else "chromium")
    else if firefoxCfg.enable || firefoxCfg.nightly.enable then
      (if firefoxCfg.nightly.enable then "firefox-nightly" else "firefox")
    else if zenCfg.enable then
      "zen"
    else if chromeCfg.enable then
      (if chromeCfg.googleChrome.enable then "google-chrome" else "chromium")
    else
      "firefox";
in
{
  options.myFeatures.platforms.styling.niriKeybinds.enable =
    lib.mkEnableOption "Apollo's Niri Keybinds";

  config = lib.mkIf cfg.enable {
    myFeatures.platforms.desktops.niri.settings = {
      binds = {
        # --- Apps & System ---
        "Mod+Q".spawn = [ "ghostty" ];
        "Mod+Shift+Q".spawn = [ defaultBrowserCmd ];
        "Mod+D".spawn =
          if config.myFeatures.platforms.addons.noctalia-v5.enable then
            [
              "noctalia"
              "msg"
              "panel-toggle"
              "launcher"
            ]
          else if config.myFeatures.platforms.addons.noctalia-shell.enable then
            [
              "noctalia-shell"
              "ipc"
              "call"
              "launcher"
              "toggle"
            ]
          else
            [ "fuzzel" ];
        "Mod+Space".spawn =
          if config.myFeatures.platforms.addons.noctalia-v5.enable then
            [
              "noctalia"
              "msg"
              "panel-toggle"
              "launcher"
            ]
          else if config.myFeatures.platforms.addons.noctalia-shell.enable then
            [
              "noctalia-shell"
              "ipc"
              "call"
              "launcher"
              "toggle"
            ]
          else
            [ "fuzzel" ];
        "Mod+O".toggle-overview = { };
        "Mod+C".close-window = { };
        "Mod+Shift+E".quit = { };
        "Mod+Super+L".spawn = [ "niri-lock" ];
        "Super+Alt+L".spawn = [ "niri-lock" ];
      }
      // lib.optionalAttrs config.myFeatures.platforms.addons.noctalia-shell.enable {
        "Mod+S".spawn = [
          "noctalia-shell"
          "--toggle-dashboard"
        ];
        "Mod+Y".spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "launcher"
          "clipboard"
        ];
        "Mod+N".spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "notifications"
          "toggle"
        ];
        "Mod+Escape".spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "session"
          "toggle"
        ];
      }
      // lib.optionalAttrs config.myFeatures.platforms.addons.noctalia-v5.enable {
        "Mod+S".spawn = [
          "noctalia"
          "msg"
          "panel-toggle"
          "dashboard"
        ];
        "Mod+Y".spawn = [
          "noctalia"
          "msg"
          "launcher"
          "clipboard"
        ];
        "Mod+N".spawn = [
          "noctalia"
          "msg"
          "panel-toggle"
          "notifications"
        ];
        "Mod+Escape".spawn = [
          "noctalia"
          "msg"
          "panel-toggle"
          "session"
        ];
      }
      // {
        # --- Navigation ---
        "Mod+Left".focus-column-left = { };
        "Mod+Right".focus-column-right = { };
        "Mod+Up".focus-window-up = { };
        "Mod+Down".focus-window-down = { };
        "Mod+Home".focus-column-first = { };
        "Mod+End".focus-column-last = { };

        # --- Move Windows ---
        "Mod+Ctrl+Left".move-column-left = { };
        "Mod+Ctrl+Right".move-column-right = { };
        "Mod+Ctrl+Up".move-window-up = { };
        "Mod+Ctrl+Down".move-window-down = { };

        # --- Monitor Navigation ---
        "Mod+Shift+Left".focus-monitor-left = { };
        "Mod+Shift+Right".focus-monitor-right = { };
        "Mod+Ctrl+Shift+Left".move-column-to-monitor-left = { };
        "Mod+Ctrl+Shift+Right".move-column-to-monitor-right = { };

        # --- Workspace Navigation ---
        "Mod+WheelScrollDown".focus-workspace-down = { };
        "Mod+WheelScrollUp".focus-workspace-up = { };
        "Mod+TouchpadScrollDown".focus-workspace-down = { };
        "Mod+TouchpadScrollUp".focus-workspace-up = { };

        # --- Layout & Window Management ---
        "Mod+Comma".consume-window-into-column = { };
        "Mod+Period".expel-window-from-column = { };
        "Mod+BracketLeft".consume-or-expel-window-left = { };
        "Mod+BracketRight".consume-or-expel-window-right = { };
        "Mod+W".toggle-column-tabbed-display = { };
        "Mod+K".center-column = { };
        "Mod+Ctrl+C".center-visible-columns = { };
        "Mod+R".switch-preset-column-width = { };
        "Mod+Shift+R".switch-preset-column-width-back = { };
        "Mod+Ctrl+R".reset-window-height = { };
        "Mod+E".expand-column-to-available-width = { };
        "Mod+Ctrl+F".expand-column-to-available-width = { };

        # --- Show Keybinds ---
        "Mod+Shift+slash".show-hotkey-overlay = { };

        # --- Resizing & Columns ---
        "Mod+Minus".set-column-width = "-10%";
        "Mod+Equal".set-column-width = "+10%";
        "Mod+Shift+Minus".set-window-height = "-10%";
        "Mod+Shift+Equal".set-window-height = "+10%";
        "Mod+F".maximize-column = { };
        "Mod+M".maximize-window-to-edges = { };
        "Mod+Shift+F".fullscreen-window = { };
        "Mod+V".toggle-window-floating = { };
        "Mod+Shift+V".switch-focus-between-floating-and-tiling = { };

        # --- Workspace Navigation & Controls ---
        "Mod+Page_Down".focus-workspace-down = { };
        "Mod+Page_Up".focus-workspace-up = { };
        "Mod+Shift+Page_Down".move-workspace-down = { };
        "Mod+Shift+Page_Up".move-workspace-up = { };
        "Mod+Ctrl+Page_Down".move-column-to-workspace-down = { };
        "Mod+Ctrl+Page_Up".move-column-to-workspace-up = { };

        # --- 9 Workspaces (Focus) ---
        "Mod+1".focus-workspace = 1;
        "Mod+2".focus-workspace = 2;
        "Mod+3".focus-workspace = 3;
        "Mod+4".focus-workspace = 4;
        "Mod+5".focus-workspace = 5;
        "Mod+6".focus-workspace = 6;
        "Mod+7".focus-workspace = 7;
        "Mod+8".focus-workspace = 8;
        "Mod+9".focus-workspace = 9;

        # --- 9 Workspaces (Move Column) ---
        "Mod+Shift+1".move-column-to-workspace = 1;
        "Mod+Shift+2".move-column-to-workspace = 2;
        "Mod+Shift+3".move-column-to-workspace = 3;
        "Mod+Shift+4".move-column-to-workspace = 4;
        "Mod+Shift+5".move-column-to-workspace = 5;
        "Mod+Shift+6".move-column-to-workspace = 6;
        "Mod+Shift+7".move-column-to-workspace = 7;
        "Mod+Shift+8".move-column-to-workspace = 8;
        "Mod+Shift+9".move-column-to-workspace = 9;

        # --- Brightness & Audio (Media) ---
        "XF86MonBrightnessUp" = {
          allow-when-locked = true;
          spawn =
            if config.myFeatures.platforms.addons.swayosd.enable then
              [ "swayosd-client" "--brightness" "+5" ]
            else
              [
                "brightnessctl"
                "set"
                "5%+"
              ];
        };
        "XF86MonBrightnessDown" = {
          allow-when-locked = true;
          spawn =
            if config.myFeatures.platforms.addons.swayosd.enable then
              [ "swayosd-client" "--brightness" "-5" ]
            else
              [
                "brightnessctl"
                "set"
                "5%-"
              ];
        };
        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          spawn =
            if config.myFeatures.platforms.addons.swayosd.enable then
              [ "swayosd-client" "--output-volume" "raise" ]
            else
              [
                "wpctl"
                "set-volume"
                "-l"
                "1.0"
                "@DEFAULT_AUDIO_SINK@"
                "5%+"
              ];
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          spawn =
            if config.myFeatures.platforms.addons.swayosd.enable then
              [ "swayosd-client" "--output-volume" "lower" ]
            else
              [
                "wpctl"
                "set-volume"
                "@DEFAULT_AUDIO_SINK@"
                "5%-"
              ];
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          spawn =
            if config.myFeatures.platforms.addons.swayosd.enable then
              [ "swayosd-client" "--output-volume" "mute-toggle" ]
            else
              [
                "wpctl"
                "set-mute"
                "@DEFAULT_AUDIO_SINK@"
                "toggle"
              ];
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          spawn =
            if config.myFeatures.platforms.addons.swayosd.enable then
              [ "swayosd-client" "--input-volume" "mute-toggle" ]
            else
              [
                "wpctl"
                "set-mute"
                "@DEFAULT_AUDIO_SOURCE@"
                "toggle"
              ];
        };
        "XF86AudioPlay" = {
          allow-when-locked = true;
          spawn = [
            "playerctl"
            "play-pause"
          ];
        };
        "XF86AudioNext" = {
          allow-when-locked = true;
          spawn = [
            "playerctl"
            "next"
          ];
        };
        "XF86AudioPrev" = {
          allow-when-locked = true;
          spawn = [
            "playerctl"
            "previous"
          ];
        };

        # --- Screenshots ---
        "Print".screenshot = { };
        "Ctrl+Print".screenshot-screen = { };
        "Alt+Print".screenshot-window = { };
      };
    };
  };
}
