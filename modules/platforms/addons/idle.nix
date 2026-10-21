# modules/platforms/addons/idle.nix
#
# Configures `swayidle` monitor DPMS timeouts and `systemd-logind` lid-switch
# suspend behavior on Linux.
{
  config,
  lib,
  isDarwin,
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
        services.logind.settings.Login = {
          HandleLidSwitch = "suspend";
          HandleLidSwitchExternalPower = "suspend";
          HandleLidSwitchDocked = "ignore";
          LidSwitchIgnoreInhibited = "yes";
        };
      })
    ]
  );
}
