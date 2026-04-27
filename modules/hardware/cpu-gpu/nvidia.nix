{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.hardware.cpu-gpu.nvidia;
in
{
  options.myFeatures.hardware.cpu-gpu.nvidia = {
    enable = lib.mkEnableOption "Nvidia Proprietary Drivers";
    beta = lib.mkEnableOption "Use Nvidia Beta Driver Channel";
    open = lib.mkEnableOption "Use Open Source Kernel Modules (Modern)";
    legacy = lib.mkEnableOption "Use Legacy Driver Branch (for P2000/Pascal)";
  };

  config = lib.mkIf cfg.enable {
    myFeatures.hardware.system.graphics.enable = true;
    services.xserver.videoDrivers = lib.mkBefore [ "nvidia" ];

    boot = {
      kernelParams = [
        "nvidia-drm.modeset=1"
        "nvidia.nvreg_preserve_video_memory_allocations=1"
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

      # Advanced package selection logic
      package =
        let
          pkgs-nvidia = config.boot.kernelPackages.nvidiaPackages;
        in
        if cfg.legacy then
          pkgs-nvidia.legacy_580 # Explicitly for your P2000
        else if cfg.beta then
          pkgs-nvidia.beta
        else if cfg.open then
          pkgs-nvidia.open
        else
          pkgs-nvidia.stable;
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
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
    };
  };
}
