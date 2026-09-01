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

    appArmor = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable AppArmor kernel module and profile enforcement.";
      };
    };

    oomd = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Systemd OOMD memory pressure monitoring daemon.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures.core.security.security = {
      enable = lib.mkDefault true;
      useAppArmor = lib.mkIf cfg.appArmor.enable (lib.mkDefault true);
      useOOMD = lib.mkIf cfg.oomd.enable (lib.mkDefault true);
    };
  };
}
