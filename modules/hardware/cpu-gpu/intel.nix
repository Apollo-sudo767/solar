{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.hardware.cpu-gpu.intel;
in
{
  options.myFeatures.hardware.cpu-gpu.intel.enable = lib.mkEnableOption "Intel Graphics Support";

  config = lib.mkIf cfg.enable {
    myFeatures.hardware.system.graphics.enable = true;

    # Ensure the kernel uses the correct driver for modern Intel iGPUs
    boot.initrd.kernelModules = [ "i915" ];
    services.xserver.videoDrivers = lib.mkDefault [ "modesetting" ];

    hardware.graphics.extraPackages = with pkgs; [
      intel-media-driver # Modern iHD driver for Broadwell+
      intel-vaapi-driver # Older i965 driver (Keep for compatibility)
      libvdpau-va-gl
    ];

    hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
    ];

    environment.variables = {
      # Forces the use of the modern Intel Media Driver for VA-API
      LIBVA_DRIVER_NAME = "iHD";
    };
  };
}
