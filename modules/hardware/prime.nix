{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.hardware.nvidia.prime;
in
{
  options.myFeatures.hardware.nvidia.prime = {
    enable = lib.mkEnableOption "Nvidia PRIME Offload Mode (Laptop)";
    intelBusId = lib.mkOption { type = lib.types.str; default = "PCI:0:2:0"; };
    nvidiaBusId = lib.mkOption { type = lib.types.str; default = "PCI:1:0:0"; };
  };

  config = lib.mkIf cfg.enable {
    # Ensure Nvidia is enabled if PRIME is enabled
    myFeatures.hardware.nvidia.enable = lib.mkDefault true;

    hardware.nvidia.prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = cfg.intelBusId;
      nvidiaBusId = cfg.nvidiaBusId;
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
