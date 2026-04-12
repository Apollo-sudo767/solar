{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.hardware.nvidia;
in
{
  options.myFeatures.hardware.nvidia = {
    enable = lib.mkEnableOption "Nvidia Proprietary Drivers";
    beta = lib.mkEnableOption "Use Nvidia Beta Driver Channel";
    open = lib.mkEnableOption "Use Open Source Kernel Modules (Modern)";
  };

  config = lib.mkIf cfg.enable {
    myFeatures.hardware.graphics.enable = true;

    services.xserver.videoDrivers = [ "nvidia" ];

    boot = {
      kernelParams = [
        "nvidia-drm.modeset=1"
        "nvidia.NVREG_PreserveVideoMemoryAllocations=1"
        "nvidia-drm.fbdev=1"
        "video=DP-1:2560x1440@180e"
        "nvidia.NVreg_PrimaryDisplay=DP-1"
      ];
      initrd.kernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
      ];
    };
    
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true; # Recommended for modern Wayland/Niri
      open = cfg.open; # Now uses the toggle
      nvidiaSettings = true;
      forceFullCompositionPipeline = true;
      
      # Select package based on beta toggle
      package = if cfg.beta 
                then config.boot.kernelPackages.nvidiaPackages.beta 
                else config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # ... keep the rest of your VA-API and environment.variables exactly as they were ...
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

    environment.variables = {
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
    };
  };
}
