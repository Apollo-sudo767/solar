{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myFeatures.platforms.addons.swaybg;
in
{
  options.myFeatures.platforms.addons.swaybg.enable = lib.mkEnableOption "swaybg service";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.myFeatures.core.users.usernames (name: {
      systemd.user.services.swaybg = {
        Unit = {
          Description = "Wallpaper";
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${config.stylix.image} -m fill";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    });
  };
}
