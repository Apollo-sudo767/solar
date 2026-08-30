{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.hardened;
in
{
  options.myFeatures.suites.hardened = {
    enable = lib.mkEnableOption "Security Hardening Suite (AppArmor, OOMD)";
  };

  config = lib.mkIf cfg.enable {
    myFeatures.core.security.security = {
      enable = lib.mkDefault true;
      useAppArmor = lib.mkDefault true;
      useOOMD = lib.mkDefault true;
    };
  };
}
