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
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      hardware = {
        peripherals = {
          battery.enable = lib.mkDefault true;
          bluetooth.enable = lib.mkDefault true;
          wifi.enable = lib.mkDefault true;
        };
        input.trackpad.enable = lib.mkDefault true;
      };

      platforms.addons.idle.enable = lib.mkDefault true;
    };
  };
}
