{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.idle;
in
{
  options.myFeatures.platforms.addons.idle.enable = lib.mkEnableOption "Swayidle/lock service";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home-manager.sharedModules = [
          (lib.optionalAttrs (!isDarwin) {
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
          })
        ];
      }
      (lib.optionalAttrs (!isDarwin) {
        services.logind.settings.Login.HandlelidSwitch = "suspend";
      })
    ]
  );
}
