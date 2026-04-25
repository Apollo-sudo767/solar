{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.services.printing;
in
{
  options.myFeatures.services.printing.enable = lib.mkEnableOption "CUPS Printing Support";

  config = lib.mkIf cfg.enable {
    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
