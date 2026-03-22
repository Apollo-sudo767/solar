{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.systems.waybar;
  usernames = config.myFeatures.core.users.usernames;
in {
  options.myFeatures.systems.waybar.enable = lib.mkEnableOption "waybar status bar";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs usernames (name: {
      programs.waybar = {
        enable = true;
        systemd.enable = true;
        
        settings.mainbar = {
          layer = "top";
          position = "bottom";
          height = 30;
          modules-left = [ "custom/power" "niri/workspaces" "niri/window" ];
          modules-center = [ "custom/branding" "mpris" ];
          modules-right = [ "cpu" "memory" "pulseaudio" "clock" "tray" ];

          "custom/power" = {
            format = "⏻";
            tooltip = "click: suspend | right-click: shutdown | middle-click: reboot";
            on-click = "systemctl suspend";
            on-click-right = "systemctl poweroff";
            on-click-middle = "systemctl reboot";
            interval = 0;
          };

          "niri/workspaces" = {
            format = "{icon}";
            on-click = "activate";
            sort-by-number = true;
            disable-scroll = false;
            format-icons = {
              default = "";
              focused = "";
              urgent = "";
            };
          };

          "niri/window" = {
            format = "{title}";
            icon-size = 18;
          };

          "custom/branding" = {
            format = " apollo - gruvbox ";
            tooltip = false;
          };

          "mpris" = {
            format = "|  {player_icon} {artist} - {title}";
            format-paused = "|  {status_icon} <i>{artist} - {title}</i>";
            player-icons = {
              default = "";
              spotify = "";
              ncspot = "";
              vlc = "󰕼";
              cmus = "󰓠";
            };
            status-icons = {
              paused = "";
              playing = "";
            };
            tooltip = true;
            max-length = 60;
            on-click = "playerctl play-pause";
            on-click-right = "playerctl next";
          };

          "cpu" = {
            format = "cpu: {usage}%";
            interval = 5;
          };

          "memory" = {
            format = "ram: {}%";
            interval = 5;
          };

          "pulseaudio" = {
            format = "{icon} {volume}% {format_source}";
            format-bluetooth = " {icon} {volume}% {format_source}";
            format-bluetooth-muted = "  {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = " {volume}%";
            format-source-muted = "";
            format-icons.default = [ "" "" "" ];
            on-click = "pavucontrol";
          };

          "clock" = {
            format = "󰥔    {:%h:%m  %a, %b %e}";
            tooltip-format = "<big>{:%y %b}</big>\n<tt><small>{calendar}</small></tt>";
            interval = 60;
          };

          "tray" = {
            icon-size = 16;
            spacing = 10;
          };
        };

        style = ''
          /* gruvbox dark soft palette */
          @define-color bg0-hard #1d2021;
          @define-color bg0-soft #32302f;
          @define-color bg1 #3c3836;
          @define-color fg0 #fbf1c7;
          @define-color fg1 #ebdbb2;
          @define-color border #504945;
          @define-color red #cc241d;
          @define-color green #98971a;
          @define-color yellow #d79921;
          @define-color blue #458588;
          @define-color purple #b16286;
          @define-color aqua #689d6a;
          @define-color orange #d65d0e;

          * {
            font-family: "firacode nerd font", monospace;
            border: none;
            border-radius: 0;
            font-size: 10px;
            font-weight: 500;
            letter-spacing: -0.5px;
            min-height: 0;
          }

          window#waybar {
            background-color: @bg0-soft;
            color: @fg1;
            border-bottom: 1px solid @border;
          }

          #custom-power,
          #workspaces button,
          #window,
          #custom-branding,
          #mpris,
          #cpu,
          #memory,
          #pulseaudio,
          #clock,
          #tray {
            padding: 0 10px;
            margin: 0;
            background-color: @bg0-soft;
            color: @fg1;
            transition: background-color 0.2s, color 0.2s;
          }

          /* --- specific module styling --- */

          #custom-power {
            background-color: @red;
            color: @fg0;
          }

          #workspaces button {
            background-color: @bg0-soft;
          }

          #workspaces button.focused {
            background-color: @blue;
            color: @fg0;
          }

          #workspaces button.urgent {
            background-color: @red;
            color: @fg0;
          }

          #window {
            background-color: @bg1;
            color: @green;
            font-weight: bold;
          }

          #custom-branding {
            background-color: @bg1;
            color: @purple;
            font-weight: bold;
          }

          #mpris {
            background-color: @bg1;
            color: @purple;
          }

          #mpris.playing { color: @green; }
          #mpris.paused { color: @yellow; }

          #cpu { background-color: @bg1; color: @blue; }
          #memory { background-color: @bg1; color: @purple; }
          #pulseaudio { background-color: @bg1; color: @aqua; }
          #clock { background-color: @bg1; }
          #tray { background-color: @bg1; }
        '';
      };
    });
  };
}
