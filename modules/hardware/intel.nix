{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.hardware.intel;
in
{
  options.myFeatures.hardware.intel.enable = lib.mkEnableOption "Intel Graphics Support";

  config = lib.mkIf cfg.enable {
    myFeatures.hardware.graphics.enable = true;

    # Ensure the kernel uses the correct driver for modern Intel iGPUs
    boot.initrd.kernelModules = [ "i915" ];

    # FIX: Correct washed out colors and stability on external monitors (T14 Gen 2 + Dock)
    boot.kernelParams = [ 
      "i915.enable_fbc=1" 
      "i915.enable_psr=0" 
      "i915.modeset=1"
    ];

    services.xserver.videoDrivers = [ "modesetting" ];

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # Modern iHD driver for Broadwell+
        intel-vaapi-driver # VA-API driver
        libvdpau-va-gl
        intel-compute-runtime # OpenCL
        vulkan-loader
        mesa
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        intel-media-driver
        intel-vaapi-driver
        mesa
      ];
    };

    environment.variables = {
      # Forces the use of the modern Intel Media Driver for VA-API
      LIBVA_DRIVER_NAME = "iHD";
    };
  };
}
