{ config, lib, pkgs, isDarwin, ... }:

let
  cfg = config.myFeatures.hardware.amd;
in
{
  options.myFeatures.hardware.amd = {
    # Set to false by default to prevent accidental driver loading
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable AMD CPU Support (P-State/Microcode)";
    };
    gpu = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable AMD GPU Support (amdgpu drivers)";
    };
  };

  # mkMerge takes a LIST of sets.
  config = lib.mkMerge [
    
    # 1. CPU Logic (Shielded for Linux only)
    (lib.mkIf cfg.enable (lib.optionalAttrs (!isDarwin) {
      hardware.cpu.amd.updateMicrocode = true;
      boot.kernelParams = [ "amd_pstate=active" ];
    }))

    # 2. GPU Logic (Shielded for Linux only)
    (lib.mkIf cfg.gpu (lib.optionalAttrs (!isDarwin) {
      myFeatures.hardware.graphics.enable = true;
      boot.initrd.kernelModules = [ "amdgpu" ];
      services.xserver.videoDrivers = [ "amdgpu" ];

      hardware.graphics.extraPackages = with pkgs; [
        amdvlk
        rocmPackages.clr
        libva-utils
      ];

      environment.variables.AMD_VULKAN_ICD = "RADV";
    }))
    
  ];
}
