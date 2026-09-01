{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.laptop;
in
{
  options.myFeatures.suites.laptop = {
    enable = lib.mkEnableOption "Laptop Suite (Battery, Bluetooth, WiFi, Trackpad & Power Management)";

    battery = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable battery charge thresholds and TLP power profile optimizations.";
      };
    };

    bluetooth = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Bluetooth peripheral support.";
      };
    };

    wifi = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable WiFi network stack and state persistence.";
      };
    };

    trackpad = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable multi-touch trackpad gestures and natural scrolling.";
      };
    };

    idle = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable automatic idle screen locking and display sleep.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      hardware = {
        peripherals = {
          battery.enable = lib.mkIf cfg.battery.enable (lib.mkDefault true);
          bluetooth.enable = lib.mkIf cfg.bluetooth.enable (lib.mkDefault true);
          wifi.enable = lib.mkIf cfg.wifi.enable (lib.mkDefault true);
        };
        input.trackpad.enable = lib.mkIf cfg.trackpad.enable (lib.mkDefault true);
      };

      platforms.addons.idle.enable = lib.mkIf cfg.idle.enable (lib.mkDefault true);
    };
  };
}
