{ config, lib, pkgs, ... }:

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

  config = lib.mkMerge [
    # CPU Logic (For your 7800X3D)
    (lib.mkIf cfg.enable {
      hardware.cpu.amd.updateMicrocode = true;
      boot.kernelParams = [ "amd_pstate=active" ];
    })

    # GPU Logic (Only for AMD Cards)
    (lib.mkIf cfg.gpu {
      myFeatures.hardware.graphics.enable = true;
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
