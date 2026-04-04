{ config, lib, pkgs, isStable, inputs, ... }:

let
  cfg = config.myFeatures.systems.presets.niriKeybinds;
  dynamicVersion = if isStable then "25.11" else "26.05";
in
{
  options.myFeatures.systems.presets.niriKeybinds.enable = lib.mkEnableOption "Apollo's Niri Keybinds";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.myFeatures.core.users.usernames (name: { config, ... }: {
      imports = [ inputs.niri.homeModules.niri ];
      home.stateVersion = dynamicVersion;

      programs.niri = {
        enable = true;
        settings = {
          input = {
            mod-key = "Alt";
            mod-key-nested = "Super";

            touchpad = {
              tap = true;
              dwt = false;
              natural-scroll = true;
              accel-speed = 0.2;
              accel-profile = "adaptive";
              click-method = "clickfinger"; 
            };

            touch = {
              map-to-output = "eDP-1"; 
            };
          };

          outputs = {
            "DP-1" = {
              mode = { width = 2560; height = 1440; refresh = 180.0; };
              position = { x = 0; y = 0; };
            };
            "DP-2" = {
              mode = { width = 1920; height = 1080; refresh = 165.0; };
              position = { x = 2560; y = 0; }; 
            };
          };

          binds = {
            # --- Apps ---
            "Mod+Q".action.spawn = [ "ghostty" ];
            "Mod+Shift+Q".action.spawn = [ "firefox" ];
            "Mod+D".action.spawn = [ "fuzzel" ];
            "Mod+C".action.close-window = { };
            "Mod+Shift+E".action.quit = { };
            "Mod+Super+L".action.spawn = [ "swaylock" ];

            # --- Navigation ---
            "Mod+Left".action.focus-column-left = { };
            "Mod+Right".action.focus-column-right = { };
            "Mod+Up".action.focus-window-up = { };
            "Mod+Down".action.focus-window-down = { };

            # --- Move Windows ---
            "Mod+Ctrl+Left".action.move-column-left = { };
            "Mod+Ctrl+Right".action.move-column-right = { };
            "Mod+Ctrl+Up".action.move-window-up = { };
            "Mod+Ctrl+Down".action.move-window-down = { };

            # --- Monitor Navigation ---
            "Mod+Shift+Left".action.focus-monitor-left = { };
            "Mod+Shift+Right".action.focus-monitor-right = { };
            "Mod+Ctrl+Shift+Left".action.move-column-to-monitor-left = { };
            "Mod+Ctrl+Shift+Right".action.move-column-to-monitor-right = { };

            # --- Layout Management (FIXED) ---
            "Mod+Comma".action.consume-window-into-column = { };
            "Mod+Period".action.expel-window-from-column = { };

            # --- Show Keybinds ---
            "Mod+Shift+slash".action.show-hotkey-overlay = { };

            # --- Resizing & Columns ---
            "Mod+Minus".action.set-column-width = "-10%";
            "Mod+Equal".action.set-column-width = "+10%";
            "Mod+F".action.maximize-column = { };
            "Mod+Shift+F".action.fullscreen-window = { };
            "Mod+V".action.toggle-window-floating = { };

            # --- 9 Workspaces (Focus) ---
            "Mod+1".action.focus-workspace = 1;
            "Mod+2".action.focus-workspace = 2;
            "Mod+3".action.focus-workspace = 3;
            "Mod+4".action.focus-workspace = 4;
            "Mod+5".action.focus-workspace = 5;
            "Mod+6".action.focus-workspace = 6;
            "Mod+7".action.focus-workspace = 7;
            "Mod+8".action.focus-workspace = 8;
            "Mod+9".action.focus-workspace = 9;

            # --- 9 Workspaces (Move) ---
            "Mod+Shift+1".action.move-column-to-workspace = 1;
            "Mod+Shift+2".action.move-column-to-workspace = 2;
            "Mod+Shift+3".action.move-column-to-workspace = 3;
            "Mod+Shift+4".action.move-column-to-workspace = 4;
            "Mod+Shift+5".action.move-column-to-workspace = 5;
            "Mod+Shift+6".action.move-column-to-workspace = 6;
            "Mod+Shift+7".action.move-column-to-workspace = 7;
            "Mod+Shift+8".action.move-column-to-workspace = 8;
            "Mod+Shift+9".action.move-column-to-workspace = 9;

            # --- Brightness Controls ---
            "XF86MonBrightnessUp".action.spawn = [ "brightnessctl" "set" "5%+" ];
            "XF86MonBrightnessDown".action.spawn = [ "brightnessctl" "set" "5%-" ];

            # --- Volume Controls ---
            "XF86AudioRaiseVolume".action.spawn = [ "wpctl" "set-volume" "-l" "1.0" "@DEFAULT_AUDIO_SINK@" "5%+" ];
            "XF86AudioLowerVolume".action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-" ];
            "XF86AudioMute".action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];

            # --- Media Controls ---
            "XF86AudioPlay".action.spawn = [ "playerctl" "play-pause" ];
            "XF86AudioNext".action.spawn = [ "playerctl" "next" ];
            "XF86AudioPrev".action.spawn = [ "playerctl" "previous" ];

            # --- Screenshots ---
            "Print".action.screenshot = { };
            "Ctrl+Print".action.screenshot-screen = { };
            "Alt+Print".action.screenshot-window = { };
          };
        };
      };
    });
  };
}
