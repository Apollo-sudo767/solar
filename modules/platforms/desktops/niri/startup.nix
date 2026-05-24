{ config, lib, ... }:

let
  cfg = config.myFeatures.platforms.desktops.niri;
in
{
  config = lib.mkIf cfg.enable {
    myFeatures.platforms.desktops.niri.extraConfig = [
      ''
        spawn-at-startup "dbus-update-activation-environment" "--systemd" "DISPLAY" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP"
        spawn-at-startup "systemctl" "--user" "start" "graphical-session.target"
        ${lib.optionalString config.myFeatures.platforms.addons.noctalia-shell.enable ''
          spawn-at-startup "noctalia-shell"
        ''}
      ''
    ];
  };
}
