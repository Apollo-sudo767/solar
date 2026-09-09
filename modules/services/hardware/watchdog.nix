{ config, lib, ... }:

let
  cfg = config.services.watchdog;
in
{
  options.services.watchdog = {
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

  config = lib.mkIf cfg.enable {
    systemd.settings.Manager = {
      RuntimeWatchdogSec = cfg.runtimeTime;
      RebootWatchdogSec = cfg.rebootTime;
      KExecWatchdogSec = cfg.kexecTime;
    };

    boot.kernel.sysctl = {
      "kernel.panic" = 10; # Reboot automatically 10 seconds after kernel panic
      "kernel.panic_on_oops" = 1;
    };
  };
}
