{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.hardware.ttyResolution;
in

{
  options.myFeatures.hardware.ttyResolution = {
    enable = lib.mkEnableOption "Fixes tty scaling issues with 1440p";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelParams = [ "video=2560x1440@60" ];
  };
}
