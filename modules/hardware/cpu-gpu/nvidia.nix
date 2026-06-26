{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
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

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        myFeatures.hardware.system.graphics.enable = true;
      }
      (lib.optionalAttrs (!isDarwin) {
        services.xserver.videoDrivers = lib.mkBefore [ "nvidia" ];

        boot = {
          kernelParams = [
            "nvidia-drm.modeset=1"
            "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
            "nvidia.NVreg_TemporaryFilePath=/var/tmp"
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
          inherit (cfg) open;
          nvidiaSettings = true;

          # Advanced package selection logic
          package =
            let
              pkgs-nvidia = config.boot.kernelPackages.nvidiaPackages;
            in
            if cfg.legacy then
              pkgs-nvidia.legacy_580 # Explicitly for your P2000
            else if cfg.beta then
              pkgs-nvidia.beta
            else if cfg.open && (pkgs-nvidia ? open) then
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
          __GL_GSYNC_ALLOWED = "0";
          __GL_VRR_ALLOWED = "0";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          GBM_BACKEND = "nvidia-drm";
          LIBVA_DRIVER_NAME = lib.mkForce (
            if config.myFeatures.hardware.cpu-gpu.nvidia.prime.enable then "iHD" else "nvidia"
          );
        };
      })
    ]
  );
}
