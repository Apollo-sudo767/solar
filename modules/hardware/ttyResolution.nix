{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.hardware.ttyResolution;
in

{
  options.myFeatures.hardware.ttyResolution = {
    enable = lib.mkEnableOption "Fixes tty scaling issues with 1440p";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.set-tty-resolution = {
      description = "Force TTY resolution to 1440p";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        # This forces the framebuffer to 1440p on all monitors
        ExecStart = "${pkgs.fbset}/bin/fbset -xres 2560 -yres 1440 -match";
      };
    };
  };
}
