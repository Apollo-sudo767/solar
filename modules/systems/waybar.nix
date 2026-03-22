{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.systems.waybar;
  usernames = config.myFeatures.core.users.usernames;
in {
  options.myFeatures.systems.waybar.enable = lib.mkEnableOption "Waybar status bar";

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
          modules-right = [ "cpu" "memory" "pulseaudio" "clock" "tray" ];

          "custom/power" = {
            format = "⏻";
            on-click = "systemctl suspend";
            on-click-right = "systemctl poweroff";
          };

          "niri/workspaces".format = "{icon}";
          "niri/window".format = "{title}";
          "custom/branding".format = " Apollo - Gruvbox ";

          "mpris" = {
            format = "|  {player_icon} {artist} - {title}";
            player-icons.default = "";
          };

          "pulseaudio" = {
            format = "{icon} {volume}%";
            format-icons.default = [ "" "" "" ];
          };
        };

        style = ''
          @define-color bg #32302f;
          @define-color fg #ebdbb2;
          @define-color blue #458588;
          @define-color red #cc241d;

          window#waybar {
            background-color: @bg;
            color: @fg;
            border-top: 1px solid #504945;
          }
          #custom-power { background-color: @red; padding: 0 10px; }
          #workspaces button.focused { background-color: @blue; }
          #custom-branding { font-weight: bold; color: #b16286; }
        '';
      };
    });
  };
}
