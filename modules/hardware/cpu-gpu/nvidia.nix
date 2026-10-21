# modules/hardware/cpu-gpu/nvidia.nix
# ============================================================================
# NVIDIA GPU Drivers, DRM Modesetting, Power Management & Wayland Tuning
# ============================================================================
# Configures NVIDIA proprietary or open-source kernel modules:
# - Selects between `stable`, `open` (Turing+), `beta`, and `legacy_580` (Pascal/P2000).
# - Enables `nvidia-drm.modeset=1`, `nvidia-drm.fbdev=1`, and VRAM preservation
#   across suspend/resume cycles (`NVreg_PreserveVideoMemoryAllocations=1`).
# - Overrides `btop` with CUDA GPU monitoring support.
# - Sets Wayland, GBM, VRR/G-Sync, HDR, and VA-API environment variables.
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
    # Pulls in Mesa, Vulkan loader/tools/validation-layers, and libvdpau-va-gl
    myFeatures.hardware.system.graphics.enable = true;

    # Enable NVIDIA GPU utilization telemetry in `btop`
    nixpkgs.overlays = [
      (_final: prev: {
        btop = prev.btop.override { cudaSupport = true; };
      })
    ];

    services.xserver.videoDrivers = lib.mkBefore [ "nvidia" ];

    boot = {
      kernelParams = [
        "nvidia-drm.modeset=1"
        "nvidia-drm.fbdev=1"
        "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
        "nvidia.NVreg_TemporaryFilePath=/var/tmp"
      ];
      kernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
      ];
    };

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      inherit (cfg) open;
      nvidiaSettings = true;

      # Select the appropriate NVIDIA kernel package branch
      package =
        let
          pkgs-nvidia = config.boot.kernelPackages.nvidiaPackages;
        in
        if cfg.legacy then
          pkgs-nvidia.legacy_580 # Legacy branch for Pascal / Quadro P2000 GPUs
        else if cfg.beta then
          pkgs-nvidia.beta
        else if cfg.open && (pkgs-nvidia ? open) then
          pkgs-nvidia.open
        else
          pkgs-nvidia.stable;
    };

    # NVIDIA-specific VA-API/VDPAU translation packages
    # (Core Vulkan loader/tools and libvdpau-va-gl are provided by `graphics.nix`)
    hardware.graphics.extraPackages = with pkgs; [
      nvidia-vaapi-driver
      libva-vdpau-driver
    ];

    hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [
      nvidia-vaapi-driver
    ];

    environment.variables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
      ENABLE_HDR_WSI = "1";
      DXVK_HDR = "1";
      __GL_GSYNC_ALLOWED = "1";
      __GL_VRR_ALLOWED = "1";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      # On hybrid Optimus laptops (PRIME offload), use the Intel iGPU (`iHD`) for VA-API decoding
      LIBVA_DRIVER_NAME = lib.mkForce (
        if config.myFeatures.hardware.cpu-gpu.nvidia.prime.enable then "iHD" else "nvidia"
      );
    };
  };
}
