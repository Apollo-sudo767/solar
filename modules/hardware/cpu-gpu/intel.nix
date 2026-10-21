# modules/hardware/cpu-gpu/intel.nix
# ============================================================================
# Intel Integrated & Arc Graphics Support (`i915` / `iHD` VA-API)
# ============================================================================
# Enables early KMS (`i915`), universal Mesa/Vulkan acceleration (`graphics.nix`),
# and Intel's modern `intel-media-driver` (`iHD`) for hardware video decoding
# and QuickSync transcoding (with `intel-vaapi-driver` `i965` fallback).
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.hardware.cpu-gpu.intel;
in
{
  options.myFeatures.hardware.cpu-gpu.intel.enable = lib.mkEnableOption "Intel Graphics Support";

  config = lib.mkIf cfg.enable {
    # Pulls in Mesa, Vulkan loader/tools, and libvdpau-va-gl
    myFeatures.hardware.system.graphics.enable = true;

    # Load Intel DRM kernel module in early initrd
    boot.initrd.kernelModules = [ "i915" ];
    services.xserver.videoDrivers = lib.mkDefault [ "modesetting" ];

    hardware.graphics.extraPackages = with pkgs; [
      intel-media-driver # Modern iHD VA-API driver for Broadwell (Gen 8) and newer
      intel-vaapi-driver # Legacy i965 VA-API driver for older hardware compatibility
    ];

    hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
    ];

    environment.variables = {
      # Default VA-API to the modern Intel iHD media driver
      LIBVA_DRIVER_NAME = lib.mkDefault "iHD";
    };
  };
}
