{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.swaync;
  inherit (config.myFeatures.core.system.users) usernames;
  c = config.lib.stylix.colors;
in
{
  options.myFeatures.platforms.addons.swaync.enable = lib.mkEnableOption "Sway Notification Center";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.swaynotificationcenter ];

    home-manager.users = lib.genAttrs usernames (_name: {
      services.swaync = {
        enable = true;
        settings = {
          positionX = "right";
          positionY = "top";
          layer = "overlay";
          control-center-margin-top = 10;
          control-center-margin-bottom = 10;
          control-center-margin-right = 10;
          control-center-margin-left = 10;
          notification-icon-size = 64;
          notification-body-image-height = 100;
          notification-body-image-width = 200;
          timeout = 10;
          notification-window-width = 350;
        };
        style = ''
          @define-color bg0 #${c.base00};
          @define-color bg1 #${c.base01};
          @define-color fg #${c.base05};
          @define-color blue #${c.base0D};
          @define-color red #${c.base08};

          * {
            font-family: "JetBrainsMono Nerd Font";
            font-size: 11px;
          }

          .notification-row {
            outline: none;
            margin: 10px;
            padding: 0;
          }

          .notification-row:focus,
          .notification-row:hover {
            background: @bg1;
          }

          .notification {
            border-radius: 0;
            margin: 0;
            padding: 10px;
            background: @bg0;
            color: @fg;
            border: 2px solid @blue;
          }

          .control-center {
            background: @bg0;
            color: @fg;
            border: 2px solid @blue;
            border-radius: 0;
          }
        '';
      };
    });
  };
}
