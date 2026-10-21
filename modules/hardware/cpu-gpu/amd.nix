# modules/hardware/cpu-gpu/amd.nix
# ============================================================================
# AMD CPU & Radeon GPU Hardware Support
# ============================================================================
# - `enable = true`: Enables AMD CPU microcode updates and the `amd_pstate=active`
#   autonomous frequency scaling driver.
# - `gpu = true`: Enables early KMS (`amdgpu`), RADV Vulkan ICD, ROCm OpenCL
#   compute libraries, and universal Mesa/Vulkan acceleration (`graphics.nix`).
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.hardware.cpu-gpu.amd;
in
{
  options.myFeatures.hardware.cpu-gpu.amd = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable AMD CPU Support (P-State/Microcode).";
    };
    gpu = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable AMD Radeon GPU Support (amdgpu/RADV/ROCm).";
    };
  };

  config = lib.mkMerge [
    # 1. AMD CPU Microcode & P-State Frequency Driver
    (lib.mkIf cfg.enable {
      hardware.cpu.amd.updateMicrocode = true;
      boot.kernelParams = [ "amd_pstate=active" ];
    })

    # 2. AMD Radeon GPU Drivers & Compute Stack
    (lib.mkIf cfg.gpu {
      myFeatures.hardware.system.graphics.enable = true;

      boot.initrd.kernelModules = [ "amdgpu" ];
      services.xserver.videoDrivers = [ "amdgpu" ];

      hardware.graphics.extraPackages = with pkgs; [
        amdvlk
        rocmPackages.clr
        libva-utils
      ];

      environment.variables.AMD_VULKAN_ICD = "RADV";
    })
  ];
}
