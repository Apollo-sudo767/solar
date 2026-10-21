# modules/hardware/cpu-gpu/prime.nix
# ============================================================================
# NVIDIA PRIME Render Offload (Hybrid Intel + NVIDIA Laptops)
# ============================================================================
# Configures hybrid laptop graphics (`europa`) so the Intel iGPU drives the
# desktop for battery efficiency while demanding applications can be launched
# on the discrete NVIDIA GPU via `nvidia-offload <command>`.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.hardware.cpu-gpu.nvidia.prime;
in
{
  options.myFeatures.hardware.cpu-gpu.nvidia.prime = {
    enable = lib.mkEnableOption "Nvidia PRIME Offload Mode (Laptop)";
    intelBusId = lib.mkOption {
      type = lib.types.str;
      default = "PCI:0:2:0";
      description = "PCI Bus ID of the integrated Intel GPU.";
    };
    nvidiaBusId = lib.mkOption {
      type = lib.types.str;
      default = "PCI:1:0:0";
      description = "PCI Bus ID of the discrete NVIDIA GPU.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Automatically enable the base NVIDIA driver stack when PRIME offload is enabled
    myFeatures.hardware.cpu-gpu.nvidia.enable = lib.mkDefault true;

    hardware.nvidia.prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      inherit (cfg) intelBusId nvidiaBusId;
    };

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "nvidia-offload" ''
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __NV_PRIME_RENDER_OFFLOAD_HANDLER=nvidia
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export __VK_LAYER_NV_optimus=NVIDIA_only
        exec "$@"
      '')
    ];
  };
}
