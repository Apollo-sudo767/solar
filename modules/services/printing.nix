{ config, lib, pkgs, isDarwin, ... }:

let
  cfg = config.myFeatures.services.printing;
in
{
  options.myFeatures.services.printing.enable = lib.mkEnableOption "CUPS Printing Support";

  config = lib.mkIf cfg.enable (lib.optionalAttrs (!isDarwin) {
    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  });
}
