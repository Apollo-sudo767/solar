# modules/services/hardware/watchdog.nix
# ============================================================================
# Hardware Watchdog & Kernel Panic Auto-Recovery
# ============================================================================
# Configures systemd hardware watchdog timers (`RuntimeWatchdogSec`,
# `RebootWatchdogSec`, `KExecWatchdogSec`) and kernel panic sysctls so headless
# servers (e.g. `hydra`, `pluto`, `styx`) automatically reboot and recover from
# hard hangs or kernel panics.
{ config, lib, ... }:

let
  cfg = config.myFeatures.services.hardware.watchdog;
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
