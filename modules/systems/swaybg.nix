{ config, lib, pkgs, ... }:
let
  cfg = config.myFeatures.systems.swaybg;
  theme = config.myFeatures.systems.theme.gruvbox;
in {
  options.myFeatures.systems.swaybg.enable = lib.mkEnableOption "swaybg service";

  config = lib.mkIf cfg.enable {
    home-manager.users.apollo.systemd.user.services.swaybg = {
      Unit = { Description = "Wallpaper"; After = [ "graphical-session.target" ]; };
      Service = {
        ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${theme.wallpaper} -m fill";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
