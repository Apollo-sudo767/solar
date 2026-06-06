{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.swaync;
in
{
  options.myFeatures.platforms.addons.swaync.enable = lib.mkEnableOption "Sway Notification Center";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.swaynotificationcenter ];

    home-manager.sharedModules = [
      (lib.optionalAttrs (!isDarwin) {
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
            * {
              font-family: "JetBrainsMono Nerd Font";
              font-size: 11px;
            }
          '';
        };
      })
    ];
  };
}
