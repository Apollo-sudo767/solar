{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.ironbar;
  inherit (config.myFeatures.core.system.users) usernames;
  c = config.lib.stylix.colors;
in
{
  options.myFeatures.platforms.addons.ironbar.enable = lib.mkEnableOption "Ironbar status bar";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs usernames (_name: {
      imports = [ inputs.ironbar.homeManagerModules.default ];

      programs.ironbar = {
        enable = true;
        package = inputs.ironbar.packages.${pkgs.system}.default;
        config = {
          position = "bottom";
          anchor = "bottom";
          height = 34;
          margin.bottom = 0;
          margin.top = 0;
          margin.left = 0;
          margin.right = 0;

          start = [
            {
              type = "custom";
              name = "power";
              class = "power";
              format = " ⏻ ";
              on_click_left = "systemctl suspend";
              on_click_right = "systemctl poweroff";
            }
            {
              type = "workspaces";
              all_outputs = true;
            }
          ];

          center = [
            {
              type = "mpris";
              format = "{icon} {artist} - {title}";
              max_length = 40;
            }
          ];

          end = [
            {
              type = "sys_info";
              interval.cpu = 2;
              interval.memory = 5;
              format = [
                " CPU: {cpu_usage}% "
                " RAM: {memory_usage}% "
              ];
            }
            {
              type = "volume";
              format = " {icon} {volume}% ";
            }
            {
              type = "clock";
              format = " %H:%M %a, %b %e ";
            }
            {
              type = "tray";
            }
          ];
        };

        style = ''
          @define-color bg0 #${c.base00};
          @define-color bg1 #${c.base01};
          @define-color fg #${c.base05};
          @define-color blue #${c.base0D};
          @define-color red #${c.base08};
          @define-color green #${c.base0B};
          @define-color yellow #${c.base0A};

          * {
            font-family: "JetBrainsMono Nerd Font";
            font-size: 11px;
            transition: none;
            border-radius: 0;
            border: none;
          }

          .background {
            background-color: @bg0;
            color: @fg;
            border-top: 2px solid @blue;
          }

          .power {
            background-color: @red;
            color: @bg0;
            padding: 0 10px;
          }

          .workspaces button {
            padding: 0 10px;
            color: @fg;
          }

          .workspaces button.focused {
            background-color: @blue;
            color: @bg0;
          }

          .workspaces button.urgent {
            background-color: @red;
            color: @bg0;
          }

          .mpris {
            color: @blue;
            padding: 0 10px;
          }

          .sys_info {
            padding: 0 10px;
          }

          .volume {
            color: @yellow;
            padding: 0 10px;
          }

          .clock {
            color: @fg;
            padding: 0 10px;
          }

          .tray {
            padding: 0 5px;
          }
        '';
      };
    });
  };
}
