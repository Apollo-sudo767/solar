{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myFeatures.platforms.addons.waybar;
in
{
  options.myFeatures.platforms.addons.waybar.enable = lib.mkEnableOption "waybar status bar";

  config = lib.mkIf (cfg.enable && !config.myFeatures.platforms.addons.noctalia-shell.enable) {
    environment.systemPackages = with pkgs; [
      brightnessctl
      networkmanagerapplet
      playerctl
      curl
    ];

    home-manager.sharedModules = [
      {
        programs.waybar = {
          enable = true;
          systemd.enable = true;

          settings.mainBar = {
            layer = "top";
            position = "bottom";
            height = 36;
            margin-bottom = 8;
            margin-left = 10;
            margin-right = 10;
            spacing = 8;

            modules-left = [
              "group/power"
              "niri/workspaces"
              "niri/window"
            ];
            modules-center = [
              "custom/branding"
              "group/music"
            ];
            modules-right = [
              "idle_inhibitor"
              "backlight"
              "cpu"
              "memory"
              "disk"
              "network"
              "battery"
              "pulseaudio"
              "clock"
              "tray"
            ];

            "group/power" = {
              orientation = "horizontal";
              drawer = {
                transition-duration = 500;
                children-class = "not-power";
                transition-left-to-right = true;
              };
              modules = [
                "custom/power"
                "custom/lock"
                "custom/suspend"
                "custom/reboot"
                "custom/exit"
              ];
            };

            "custom/power" = {
              format = "";
              tooltip = false;
            };

            "custom/lock" = {
              format = "󰌾";
              tooltip = false;
              on-click = "swaylock";
            };

            "custom/suspend" = {
              format = "󰤄";
              tooltip = false;
              on-click = "swaylock & systemctl suspend";
            };

            "custom/reboot" = {
              format = "󰜉";
              tooltip = false;
              on-click = "systemctl reboot";
            };

            "custom/exit" = {
              format = "󰗼";
              tooltip = false;
              on-click = "systemctl poweroff";
            };

            "niri/workspaces" = {
              format = "{icon}";
              on-click = "activate";
              format-icons = {
                default = "";
                focused = "";
                urgent = "󰀦";
              };
            };

            "niri/window" = {
              format = "󰖲 {title}";
              icon-size = 18;
              max-length = 30;
              separate-outputs = true;
            };

            "custom/branding" = {
              format = "󱄅 Apollo";
              tooltip = false;
            };

            "group/music" = {
              orientation = "horizontal";
              modules = [
                "custom/media-prev"
                "mpris"
                "custom/media-next"
              ];
            };

            "mpris" = {
              format = "{artist} - {title}";
              player-icons = {
                default = "󰎆";
                spotify = "";
                firefox = "󰈹";
              };
              status-icons = {
                playing = "󰐊";
                paused = "󰏤";
              };
              on-click = "playerctl play-pause";
              max-length = 35;
            };

            "custom/media-prev" = {
              format = "󰒮";
              on-click = "playerctl previous";
              tooltip = false;
            };

            "custom/media-next" = {
              format = "󰒭";
              on-click = "playerctl next";
              tooltip = false;
            };

            "idle_inhibitor" = {
              format = "{icon}";
              format-icons = {
                activated = "󰈈";
                deactivated = "󰈉";
              };
              tooltip = true;
              tooltip-format-activated = "Presentation Mode Active";
              tooltip-format-deactivated = "Presentation Mode Inactive";
            };

            "backlight" = {
              format = "{icon} {percent}%";
              format-icons = [
                "󰃞"
                "󰃟"
                "󰃠"
              ];
              on-scroll-up = "brightnessctl set 1%+";
              on-scroll-down = "brightnessctl set 1%-";
            };

            "cpu" = {
              format = "󰻠 {usage}%";
              interval = 2;
            };

            "memory" = {
              format = "󰍛 {percentage}%";
              interval = 2;
              tooltip-format = "RAM: {used:0.1f}GiB / {total:0.1f}GiB\nSwap: {swapUsed:0.1f}GiB / {swapTotal:0.1f}GiB";
            };

            "disk" = {
              format = "󰋊 {percentage_used}%";
              interval = 30;
              path = "/";
              tooltip-format = "{used} / {total} ({percentage_used}%)";
            };

            "network" = {
              format-wifi = "󰤨 {essid}";
              format-ethernet = "󰈀 {ifname}";
              format-disconnected = "󰖪 Disconnected";
              tooltip-format = "{ifname} via {gwaddr}\nIP: {ipaddr}\nStrength: {signalStrength}%";
              on-click = "nm-connection-editor";
            };

            "battery" = {
              states = {
                warning = 30;
                critical = 15;
              };
              format = "{icon} {capacity}%";
              format-charging = "󱐋 {capacity}%";
              format-plugged = " {capacity}%";
              format-icons = [
                "󰁺"
                "󰁻"
                "󰁼"
                "󰁽"
                "󰁾"
                "󰁿"
                "󰂀"
                "󰂁"
                "󰂂"
                "󰁹"
              ];
            };

            "pulseaudio" = {
              format = "{icon} {volume}%";
              format-muted = "󰝟 Muted";
              format-icons = {
                headphone = "󰋋";
                hands-free = "󰋋";
                headset = "󰋋";
                phone = "";
                portable = "";
                car = "";
                default = [
                  "󰕿"
                  "󰖀"
                  "󰕾"
                ];
              };
              on-click = "pavucontrol";
              on-scroll-up = "pamixer -i 1";
              on-scroll-down = "pamixer -d 1";
            };

            "clock" = {
              format = "󰥔 {:%H:%M}";
              format-alt = "󰃭 {:%Y-%m-%d}";
              tooltip-format = "<tt><small>{calendar}</small></tt>";
              calendar = {
                mode = "year";
                mode-mon-col = 3;
                weeks-pos = "right";
                on-scroll = 1;
              };
              actions = {
                on-click-right = "mode";
                on-click-forward = "tz_up";
                on-click-backward = "tz_down";
                on-scroll-up = "shift_up";
                on-scroll-down = "shift_down";
              };
            };

            "tray" = {
              icon-size = 18;
              spacing = 10;
            };
          };

          style = lib.mkForce ''
            * {
              font-family: "JetBrainsMono Nerd Font", monospace;
              font-size: 13px;
              font-weight: bold;
              min-height: 0;
              border: none;
              box-shadow: none;
            }

            window#waybar {
              background: transparent;
            }
          '';
        };
      }
    ];
  };
}
