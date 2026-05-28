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
in
{
  options.myFeatures.platforms.addons.ironbar.enable = lib.mkEnableOption "Ironbar status bar";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs usernames (_name: {
      imports = [ inputs.ironbar.homeManagerModules.default ];

      programs.ironbar = {
        enable = true;
        package = inputs.ironbar.packages.${pkgs.system}.default;
        systemd = true;
        config = {
          icon_theme = "Paper";
          position = "bottom";
          height = 34;
          anchor_to_edges = true;
          layer = "top";
          exclusive_zone = true;

          monitors = {
            "all" = {
              position = "bottom";
            };
          };

          margin = {
            bottom = 0;
            top = 0;
            left = 0;
            right = 0;
          };

          start = [
            {
              type = "workspaces";
            }
          ];

          center = [
            {
              type = "music";
              player_type = "mpd";
            }
            {
              type = "focused";
              icon_size = 16;
            }
          ];

          end = [
            {
              type = "battery";
              show_if = "ls /sys/class/power_supply/ | grep --quiet '^BAT'";
            }
            {
              type = "sys_info";
              format = [
                "{cpu_percent}% "
                "{memory_percent}% "
              ];
              interval = {
                cpu = 1;
              };
            }
            {
              type = "clipboard";
              max_items = 5;
              truncate = {
                mode = "end";
                length = 30;
              };
            }
            {
              type = "volume";
            }
            {
              type = "custom";
              name = "power-menu";
              class = "power-menu";
              bar = [
                {
                  type = "button";
                  name = "power-btn";
                  label = "󰐥";
                  on_click = "popup:toggle";
                }
              ];
              popup = [
                {
                  type = "box";
                  orientation = "vertical";
                  widgets = [
                    {
                      type = "label";
                      name = "header";
                      label = "Power menu";
                    }
                    {
                      type = "box";
                      name = "buttons";
                      widgets = [
                        {
                          type = "button";
                          class = "power-btn";
                          label = "<span>󰐥</span>";
                          on_click = "!shutdown now";
                        }
                        {
                          type = "button";
                          class = "power-btn";
                          label = "<span>󰜉</span>";
                          on_click = "!reboot";
                        }
                      ];
                    }
                  ];
                }
              ];
            }
            {
              type = "tray";
            }
            {
              type = "clock";
            }
            {
              type = "notifications";
              show_if = "pgrep -x swaync";
            }
          ];
        };

        style =
          let
            c =
              if config.stylix.enable then
                config.lib.stylix.colors
              else
                {
                  base00 = "282828";
                  base01 = "3c3836";
                  base05 = "ebdbb2";
                  base0D = "83a598";
                  base08 = "fb4934";
                  base0B = "b8bb26";
                  base0A = "fabd2f";
                };
          in
          ''
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

            .power-menu {
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

            .music {
              color: @blue;
              padding: 0 10px;
            }

            .focused {
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

            .menu, .launcher, .clipboard, .notifications, .battery {
              padding: 0 10px;
            }

            .tray {
              padding: 0 5px;
            }
          '';
      };

      systemd.user.services.ironbar = {
        Unit.After = [ "niri-session.target" ];
        Install.WantedBy = [ "niri-session.target" ];
      };
    });
  };
}
