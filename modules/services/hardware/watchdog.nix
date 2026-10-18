{ config, lib, ... }:

let
  cfg = config.myFeatures.services.hardware.watchdog;
  legacyCfg = config.services.watchdog;
  enabled = cfg.enable || legacyCfg.enable;
  runtimeTime = if cfg.enable then cfg.runtimeTime else legacyCfg.runtimeTime;
  rebootTime = if cfg.enable then cfg.rebootTime else legacyCfg.rebootTime;
  kexecTime = if cfg.enable then cfg.kexecTime else legacyCfg.kexecTime;
in
{
  options.myFeatures.services.hardware.watchdog = {
    enable = lib.mkEnableOption "kernel hardware watchdog timers for auto-recovery on system freezes";
    runtimeTime = lib.mkOption {
      type = lib.types.str;
      default = "30s";
      description = "Hardware watchdog timeout while system is running.";
    };
    rebootTime = lib.mkOption {
      type = lib.types.str;
      default = "10min";
      description = "Hardware watchdog timeout while system is rebooting.";
    };
    kexecTime = lib.mkOption {
      type = lib.types.str;
      default = "5min";
      description = "Hardware watchdog timeout during kexec.";
    };
  };

  # Backward compatibility aliases
  options.services.watchdog = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Deprecated: use myFeatures.services.hardware.watchdog.enable instead.";
    };
    runtimeTime = lib.mkOption {
      type = lib.types.str;
      default = "30s";
      description = "Deprecated";
    };
    rebootTime = lib.mkOption {
      type = lib.types.str;
      default = "10min";
      description = "Deprecated";
    };
    kexecTime = lib.mkOption {
      type = lib.types.str;
      default = "5min";
      description = "Deprecated";
    };
  };

  config = lib.mkIf enabled {
    systemd.settings.Manager = {
      RuntimeWatchdogSec = runtimeTime;
      RebootWatchdogSec = rebootTime;
      KExecWatchdogSec = kexecTime;
    };

    boot.kernel.sysctl = {
      "kernel.panic" = 10; # Reboot automatically 10 seconds after kernel panic
      "kernel.panic_on_oops" = 1;
    };
  };
}
