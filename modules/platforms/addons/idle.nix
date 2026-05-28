{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.idle;
in
{
  options.myFeatures.platforms.addons.idle.enable = lib.mkEnableOption "Swayidle/lock service";

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        services.swayidle = {
          enable = true;
          timeouts = [
            {
              timeout = 600;
              command = "niri msg action power-off-monitors";
            }
          ];
          events = {
            "after-resume" = "niri msg action power-on-monitors";
          };
        };
      }
    ];

    services.logind.settings.Login.HandlelidSwitch = "suspend";
  };
}
