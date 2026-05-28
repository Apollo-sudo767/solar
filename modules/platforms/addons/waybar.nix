{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myFeatures.platforms.addons.waybar;
  inherit (config.myFeatures.core.system.users) usernames;
in
{
  options.myFeatures.platforms.addons.waybar.enable = lib.mkEnableOption "waybar status bar";

  config = lib.mkIf (cfg.enable && !config.myFeatures.platforms.addons.noctalia-shell.enable) {
    # Ensure necessary packages are available for waybar modules
    environment.systemPackages = with pkgs; [
      brightnessctl
      networkmanagerapplet
      playerctl
      curl
    ];

    home-manager.users = lib.genAttrs usernames (_name: {
      programs.waybar =
        let
          c =
            if config.stylix.enable then
              config.lib.stylix.colors
            else
              {
                base00 = "282828";
                base01 = "3c3836";
                base02 = "504945";
                base05 = "ebdbb2";
                base08 = "fb4934";
                base0A = "fabd2f";
                base0B = "b8bb26";
                base0C = "8ec07c";
                base0D = "83a598";
                base0E = "d3869b";
              };
        in
        {
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

            "custom/media-play-pause" = {
              format = "{icon}";
              format-icons = {
                "Playing" = "󰏤";
                "Paused" = "󰐊";
                "Stopped" = "󰐊";
              };
              exec = "playerctl status";
              on-click = "playerctl play-pause";
              interval = 1;
              tooltip = false;
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
                car = "";
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
                format = {
                  months = "<span color='#${c.base0D}'><b>{}</b></span>";
                  days = "<span color='#${c.base05}'><b>{}</b></span>";
                  weeks = "<span color='#${c.base0C}'><b>W{}</b></span>";
                  weekdays = "<span color='#${c.base0A}'><b>{}</b></span>";
                  today = "<span color='#${c.base08}'><b><u>{}</u></b></span>";
                };
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
            /* Waybar Styles */
            @define-color bg0 #${c.base00};
            @define-color bg1 #${c.base01};
            @define-color bg2 #${c.base02};
            @define-color fg0 #${c.base05};
            @define-color blue #${c.base0D};
            @define-color red #${c.base08};
            @define-color green #${c.base0B};
            @define-color yellow #${c.base0A};
            @define-color purple #${c.base0E};
            @define-color aqua #${c.base0C};

            * {
              font-family: "${
                if config.stylix.enable then config.stylix.fonts.monospace.name else "monospace"
              }", "JetBrainsMono Nerd Font", monospace;
              font-size: 13px;
              font-weight: bold;
              min-height: 0;
              border: none;
              box-shadow: none;
            }

            window#waybar {
              background: transparent;
              color: @fg0;
            }

            #custom-power,
            #custom-lock,
            #custom-suspend,
            #custom-reboot,
            #custom-exit,
            #workspaces,
            #window,
            #custom-branding,
            #mpris,
            #idle_inhibitor,
            #backlight,
            #cpu,
            #memory,
            #disk,
            #network,
            #battery,
            #pulseaudio,
            #clock,
            #tray {
              background-color: alpha(@bg0, 0.7);
              padding: 0 12px;
              margin: 4px 0;
              border-radius: 10px;
              border: 1px solid rgba(255, 255, 255, 0.1);
              transition: all 0.3s ease;
              min-height: 28px;
            }

            #custom-media-prev, #custom-media-next {
              font-size: 0;
              padding: 0;
              margin: 0;
              background: transparent;
              border: none;
              opacity: 0;
              transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
              min-width: 0;
            }

            #music:hover #custom-media-prev,
            #music:hover #custom-media-next {
              font-size: 13px;
              opacity: 1;
              padding: 0 12px;
              margin: 4px 5px;
              min-width: 20px;
              background-color: alpha(@bg0, 0.7);
              border: 1px solid rgba(255, 255, 255, 0.1);
              border-radius: 10px;
            }

            /* Interactive Children in Drawers */
            #custom-lock, #custom-suspend, #custom-reboot, #custom-exit,
            #custom-media-prev, #custom-media-play-pause, #custom-media-next {
              margin-left: 5px;
            }

            #custom-power:hover,
            #custom-lock:hover,
            #custom-suspend:hover,
            #custom-reboot:hover,
            #custom-exit:hover,
            #workspaces button:hover,
            #idle_inhibitor:hover,
            #network:hover,
            #battery:hover,
            #pulseaudio:hover,
            #clock:hover {
              background-color: @bg2;
              border: 1px solid @blue;
            }

            #custom-power {
              color: @red;
            }

            #workspaces {
              padding: 0 5px;
            }

            #workspaces button {
              color: @fg0;
              padding: 0 6px;
              margin: 0 2px;
              border-radius: 6px;
              min-height: 20px;
              background: transparent;
            }

            #workspaces button.focused {
              color: @blue;
              background-color: rgba(255, 255, 255, 0.1);
            }

            #workspaces button.urgent {
              color: @red;
            }

            #window {
              color: @aqua;
            }

            #custom-branding {
              color: @purple;
            }

            #mpris {
              color: @blue;
            }

            #cpu { color: @green; }
            #memory { color: @yellow; }
            #disk { color: @aqua; }
            #network { color: @purple; }
            #battery { color: @green; }
            #battery.warning { color: @yellow; }
            #battery.critical { color: @red; }
            #pulseaudio { color: @blue; }
            #clock { color: @fg0; }

            tooltip {
              background: @bg1;
              border-radius: 10px;
              border: 2px solid @blue;
            }

            tooltip label {
              color: @fg0;
              padding: 8px;
            }
          '';
        };
    });
  };
}
