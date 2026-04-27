{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.services.hardware.printing;
in
{
  options.myFeatures.services.hardware.printing.enable = lib.mkEnableOption "CUPS Printing Support";

  config = lib.mkIf cfg.enable {
    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
