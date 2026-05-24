{ config, lib, ... }:

let
  niriCfg = config.myFeatures.platforms.desktops.niri;
  keybindsCfg = config.myFeatures.platforms.styling.niriKeybinds;
in
{
  config = lib.mkIf (niriCfg.enable && keybindsCfg.enable) {
    myFeatures.platforms.desktops.niri.extraConfig = [
      ''
        binds {
            // --- Apps & System ---
            "Mod+Q" { spawn "ghostty"; }
            "Mod+Shift+Q" { spawn "firefox"; }
            "Mod+D" {
                spawn ${
                  if config.myFeatures.platforms.addons.noctalia-shell.enable then
                    "\"noctalia-shell\" \"ipc\" \"call\" \"launcher\" \"toggle\""
                  else
                    "\"fuzzel\""
                }
            }
            "Mod+O" { toggle-overview; }
            "Mod+C" { close-window; }
            "Mod+Shift+E" { quit; }
            "Mod+Super+L" { spawn "swaylock"; }

            ${lib.optionalString config.myFeatures.platforms.addons.noctalia-shell.enable ''
              "Mod+S" { spawn "noctalia-shell" "--toggle-dashboard"; }
            ''}

            // --- Navigation ---
            "Mod+Left" { focus-column-left; }
            "Mod+Right" { focus-column-right; }
            "Mod+Up" { focus-window-up; }
            "Mod+Down" { focus-window-down; }
            "Mod+Home" { focus-column-first; }
            "Mod+End" { focus-column-last; }

            // --- Move Windows ---
            "Mod+Ctrl+Left" { move-column-left; }
            "Mod+Ctrl+Right" { move-column-right; }
            "Mod+Ctrl+Up" { move-window-up; }
            "Mod+Ctrl+Down" { move-window-down; }

            // --- Monitor Navigation ---
            "Mod+Shift+Left" { focus-monitor-left; }
            "Mod+Shift+Right" { focus-monitor-right; }
            "Mod+Ctrl+Shift+Left" { move-column-to-monitor-left; }
            "Mod+Ctrl+Shift+Right" { move-column-to-monitor-right; }

            // --- Workspace Navigation ---
            "Mod+WheelScrollDown" { focus-workspace-down; }
            "Mod+WheelScrollUp" { focus-workspace-up; }
            "Mod+TouchpadScrollDown" { focus-workspace-down; }
            "Mod+TouchpadScrollUp" { focus-workspace-up; }

            // --- Layout Management ---
            "Mod+Comma" { consume-window-into-column; }
            "Mod+Period" { expel-window-from-column; }
            "Mod+K" { center-column; }
            "Mod+R" { switch-preset-column-width; }

            // --- Show Keybinds ---
            "Mod+Shift+slash" { show-hotkey-overlay; }

            // --- Resizing & Columns ---
            "Mod+Minus" { set-column-width "-10%"; }
            "Mod+Equal" { set-column-width "+10%"; }
            "Mod+Shift+Minus" { set-window-height "-10%"; }
            "Mod+Shift+Equal" { set-window-height "+10%"; }
            "Mod+F" { maximize-column; }
            "Mod+Shift+F" { fullscreen-window; }
            "Mod+V" { toggle-window-floating; }

            // --- 9 Workspaces (Focus) ---
            "Mod+1" { focus-workspace 1; }
            "Mod+2" { focus-workspace 2; }
            "Mod+3" { focus-workspace 3; }
            "Mod+4" { focus-workspace 4; }
            "Mod+5" { focus-workspace 5; }
            "Mod+6" { focus-workspace 6; }
            "Mod+7" { focus-workspace 7; }
            "Mod+8" { focus-workspace 8; }
            "Mod+9" { focus-workspace 9; }

            // --- 9 Workspaces (Move) ---
            "Mod+Shift+1" { move-column-to-workspace 1; }
            "Mod+Shift+2" { move-column-to-workspace 2; }
            "Mod+Shift+3" { move-column-to-workspace 3; }
            "Mod+Shift+4" { move-column-to-workspace 4; }
            "Mod+Shift+5" { move-column-to-workspace 5; }
            "Mod+Shift+6" { move-column-to-workspace 6; }
            "Mod+Shift+7" { move-column-to-workspace 7; }
            "Mod+Shift+8" { move-column-to-workspace 8; }
            "Mod+Shift+9" { move-column-to-workspace 9; }

            // --- Brightness & Audio (Media) ---
            "XF86MonBrightnessUp" { spawn "brightnessctl" "set" "5%+"; }
            "XF86MonBrightnessDown" { spawn "brightnessctl" "set" "5%-"; }
            "XF86AudioRaiseVolume" { spawn "wpctl" "set-volume" "-l" "1.0" "@DEFAULT_AUDIO_SINK@" "5%+"; }
            "XF86AudioLowerVolume" { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
            "XF86AudioMute" { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
            "XF86AudioPlay" { spawn "playerctl" "play-pause"; }
            "XF86AudioNext" { spawn "playerctl" "next"; }
            "XF86AudioPrev" { spawn "playerctl" "previous"; }

            // --- Screenshots ---
            "Print" { screenshot; }
            "Ctrl+Print" { screenshot-screen; }
            "Alt+Print" { screenshot-window; }
        }
      ''
    ];
  };
}
