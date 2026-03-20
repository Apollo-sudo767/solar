{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.hardware.nvidia;
in
{
  options.myFeatures.hardware.nvidia.enable = lib.mkEnableOption "Nvidia Proprietary Drivers";

  config = lib.mkIf cfg.enable {
    # Hardware graphics must be on for Nvidia to work
    myFeatures.hardware.graphics.enable = true;

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false; # Set to true only if you have suspend issues
      open = true; # Use the modern open-source kernel modules for your 4070 Ti
      nvidiaSettings = true;
      forceFullCompositionPipeline = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # Specific Nvidia Video Acceleration
    hardware.graphics.extraPackages = with pkgs; [
      nvidia-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
      vulkan-loader
      vulkan-tools
    ];
    
    hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [
      nvidia-vaapi-driver
    ];

    # Essential "Glue" Variables for Niri + Nvidia
    environment.variables = {
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1"; # Fixes flickering cursors in Niri
      NVD_BACKEND = "direct";        # Modern VA-API backend
    };
  };
}
