{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.ironbar;
in
{
  options.myFeatures.platforms.addons.ironbar.enable = lib.mkEnableOption "Ironbar status bar";

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
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

          style = ''
            * {
              font-family: "JetBrainsMono Nerd Font";
              font-size: 11px;
            }
          '';
        };

        systemd.user.services.ironbar = {
          Unit.After = [ "niri-session.target" ];
          Install.WantedBy = [ "niri-session.target" ];
        };
      }
    ];
  };
}
