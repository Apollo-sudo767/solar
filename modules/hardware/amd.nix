{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.hardware.amd;
in
{
  options.myFeatures.hardware.amd.enable = lib.mkEnableOption "AMD GPU Support";

  config = lib.mkIf cfg.enable {
    myFeatures.hardware.graphics.enable = true;

    # Load the driver early in the boot process
    boot.initrd.kernelModules = [ "amdgpu" ];
    services.xserver.videoDrivers = [ "amdgpu" ];

    hardware.graphics.extraPackages = with pkgs; [
      amdvlk
      rocmPackages.clr # For OpenCL support
      libva-utils      # To verify with 'vainfo'
    ];

    hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [
      amdvlk
    ];

    environment.variables = {
      # Prefer RADV (Mesa) over AMDVLK for better compatibility with Niri/Wayland
      # If you prefer AMDVLK, remove the variable below.
      AMD_VULKAN_ICD = "RADV"; 
    };
  };
}
