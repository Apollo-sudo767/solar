{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.services.hardware.openrgb;
in
{
  options.myFeatures.services.hardware.openrgb.enable = lib.mkEnableOption "OpenRGB";

  config = lib.mkIf cfg.enable {
    services.hardware.openrgb = {
      enable = true;
      package = pkgs.openrgb-with-all-plugins;
    };

    # Ensure i2c-dev is loaded for motherboard/RAM control
    boot.kernelModules = [ "i2c-dev" ];

    # Add OpenRGB to system packages for GUI access
    environment.systemPackages = [ pkgs.openrgb-with-all-plugins ];
  };
}
