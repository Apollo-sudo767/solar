{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.hardware.battery;
in
{
  options.myFeatures.hardware.battery = {
    enable = lib.mkEnableOption "ThinkPad Battery Management";
    
    # New option to toggle between 80% (Health) and 100% (Performance)
    fullCharge = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to allow charging to 100%. If false, caps at 80% to preserve health.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.power-profiles-daemon.enable = false;

    services.tlp = {
      enable = true;
      settings = {
        # CPU Scaling
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        # Battery Charge Thresholds
        # If fullCharge is true, we set stop to 100. If false, we cap at 80.
        START_CHARGE_THRESH_BAT0 = if cfg.fullCharge then 95 else 75;
        STOP_CHARGE_THRESH_BAT0 = if cfg.fullCharge then 100 else 80;

        # Keep the T14 and P1 cool
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";
      };
    };

    environment.systemPackages = with pkgs; [ tpacpi-bat ];
  };
}
