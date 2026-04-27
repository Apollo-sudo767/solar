{ config, lib, pkgs, ... }:
let
  cfg = config.myFeatures.platforms.addons.waybar;
  usernames = lib.filter (n: n != "enable" && n != "usernames") config.myFeatures.core.users.usernames;
in {
  options.myFeatures.platforms.addons.waybar.enable = lib.mkEnableOption "waybar status bar";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs usernames (name: {
      programs.waybar = {
        enable = true;
        systemd.enable = true;

        settings.mainBar = {
          layer = "top";
          position = "bottom";
          height = 30;
          
          modules-left = [ "custom/power" "niri/workspaces" "niri/window" ];
          modules-center = [ "custom/branding" "mpris" ];
          # Added 'network' and 'battery' here
          modules-right = [ "cpu" "memory" "network" "battery" "pulseaudio" "clock" "tray" ];

          "custom/power" = {
            format = " ⏻ ";
            on-click = "systemctl suspend";
            on-click-right = "systemctl poweroff";
            on-click-middle = "systemctl reboot";
          };

          "niri/workspaces" = {
            format = "{index}: {icon}";
            on-click = "activate";
            format-icons = {
              default = "";
              focused = "";
              urgent = "󰀦";
            };
          };

          "niri/window" = {
            format = "{title}";
            icon-size = 18;
          };

          "custom/branding" = {
            format = " Apollo - Gruvbox ";
          };

          "mpris" = {
            format = " {player_icon} {artist} - {title} ";
            player-icons = {
              default = "▶";
              spotify = " ";
            };
            status-icons = {
              playing = " ";
              paused = " ";
            };
            max-length = 40;
          };

          "cpu" = { format = " CPU: {usage}% "; };
          "memory" = { format = " RAM: {}% "; };

          # --- Network Module ---
          "network" = {
            format-wifi = "   {essid} ";
            format-ethernet = " 󰈀  {ifname} ";
            format-disconnected = " 󰖪  Disconnected ";
            tooltip-format = "{ifname} via {gwaddr}";
            on-click = "nm-connection-editor";
          };

          # --- Battery Module ---
          "battery" = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = " {icon} {capacity}% ";
            format-charging = " 󱐋 {capacity}% ";
            format-plugged = "  {capacity}% ";
            format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          };

          "pulseaudio" = {
            format = " {icon} {volume}% ";
            format-muted = " 󰝟 Muted ";
            format-icons.default = [ "󰕿" "󰖀" "󰕾" ];
            on-click = "pavucontrol";
          };

          "clock" = {
            format = " 󰥔  {:%H:%M  %a, %b %e} ";
          };

          "tray" = {
            icon-size = 16;
            spacing = 8;
          };
        };

        style = lib.mkForce ''
          @define-color bg0 #${config.lib.stylix.colors.base00};
          @define-color bg1 #${config.lib.stylix.colors.base01};
          @define-color fg1 #${config.lib.stylix.colors.base05};
          @define-color blue #${config.lib.stylix.colors.base0D};
          @define-color red #${config.lib.stylix.colors.base08};
          @define-color green #${config.lib.stylix.colors.base0B};
          @define-color yellow #${config.lib.stylix.colors.base0A};

          * {
            font-family: "JetBrainsMono Nerd Font", monospace;
            border: none;
            border-radius: 0;
            font-size: 11px;
            margin: 0;
            padding: 0;
            min-height: 0;
          }

          window#waybar {
            background-color: @bg0;
            color: @fg1;
            border-top: 2px solid @blue;
          }

          /* Added #network and #battery to the padding list */
          #custom-power, #workspaces button, #window, #custom-branding, #mpris, 
          #cpu, #memory, #network, #battery, #pulseaudio, #clock, #tray {
            padding: 0 10px;
            margin: 0;
            background-color: transparent;
          }

          #custom-power {
            background-color: @red;
            color: @bg0;
          }

          #workspaces button.focused {
            background-color: @blue;
            color: @bg0;
          }

          #workspaces button.urgent {
            background-color: @red;
          }

          #battery.critical:not(.charging) {
            color: @red;
          }

          #battery.warning:not(.charging) {
            color: @yellow;
          }

          #window { color: @green; }
          #mpris { color: @blue; }
          #network { color: @yellow; }
          #tray { margin-right: 5px; }
        '';
      };
    });
  };
}
