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
      powerManagement.enable = true;
      open = cfg.open;
      nvidiaSettings = true;
      forceFullCompositionPipeline = true;
      
      # Correct package logic for Pascal cards like the P2000
      package = let 
        pkgs-nvidia = config.boot.kernelPackages.nvidiaPackages;
      in if cfg.beta then pkgs-nvidia.beta 
         else if cfg.open then pkgs-nvidia.open 
         else pkgs-nvidia.stable; 
    };

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
