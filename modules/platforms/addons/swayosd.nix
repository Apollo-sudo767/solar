{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.swayosd;
  inherit (config.myFeatures.core.system.users) usernames;
in
{
  options.myFeatures.platforms.addons.swayosd.enable = lib.mkEnableOption "SwayOSD";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        # SwayOSD requires udev rules and a system service for libinput/backlight access
        services.udev.packages = [ pkgs.swayosd ];
        services.dbus.packages = [ pkgs.swayosd ];
        systemd.packages = [ pkgs.swayosd ];
        systemd.services.swayosd-libinput-backend.wantedBy = [ "graphical.target" ];
      })
      {
        home-manager.users = lib.genAttrs usernames (
          _name:
          (lib.optionalAttrs (!isDarwin) {
            services.swayosd.enable = true;
          })
        );
      }
    ]
  );
}
