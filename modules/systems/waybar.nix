{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.systems.waybar;
  # Use the direct list of usernames from your core config
  usernames = config.myFeatures.core.users.usernames;
in {
  options.myFeatures.systems.waybar.enable = lib.mkEnableOption "Waybar status bar";

  config = lib.mkIf cfg.enable {
    # Ensure the package is available to the system
    environment.systemPackages = [ pkgs.waybar pkgs.pavucontrol ];

    home-manager.users = lib.genAttrs usernames (name: {
      programs.waybar = {
        enable = true;
        systemd.enable = true; # Auto-starts with Niri
        settings = {
          mainBar = {
            layer = "top";
            position = "top";
            height = 30;
            # Ensure the bar appears on all connected monitors
            output = [ "DP-5" "*" ]; 
            
            modules-left = [ "niri/window" "niri/workspaces" ];
            modules-center = [ "clock" ];
            modules-right = [ "cpu" "memory" "network" "pulseaudio" "tray" ];

            "niri/workspaces" = {
              format = "{name}";
            };

            "clock" = {
              format = "{:%H:%M | %a %d}";
              tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            };

            "cpu" = { format = "  {usage}%"; };
            "memory" = { format = "  {}%"; };

            "pulseaudio" = {
              format = "{icon} {volume}%";
              format-muted = "";
              format-icons = {
                default = [ "" "" "" ];
              };
              on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
            };
          };
        };

        style = ''
          * {
            font-family: "JetBrainsMono Nerd Font";
            font-size: 13px;
          }
          window#waybar {
            background: rgba(40, 40, 40, 0.9);
            color: #ebdbb2;
            border-bottom: 2px solid #d65d0e;
          }
          #workspaces button {
            color: #a89984;
            padding: 0 5px;
          }
          #workspaces button.active {
            color: #fabd2f;
            border-bottom: 2px solid #fabd2f;
          }
        '';
      };
    });
  };
}
