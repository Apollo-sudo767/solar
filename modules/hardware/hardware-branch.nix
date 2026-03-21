{ lib, config, pkgs, ... }:

let
  cfg = config.myFeatures.hardware;
in
{
  options.myFeatures.hardware = {
    # --- AMD NEST (7800X3D Optimizations) ---
    amd = {
      enable = lib.mkEnableOption "AMD CPU/GPU Support";
      pstate = lib.mkEnableOption "AMD P-State Driver for Zen 4";
    };

    # --- NVIDIA NEST (4070 Ti Logic) ---
    nvidia = {
      enable = lib.mkEnableOption "Nvidia Proprietary Drivers";
      beta = lib.mkEnableOption "Use Nvidia Beta Driver Channel";
      open = lib.mkEnableOption "Use Open Source Kernel Modules";
    };

    # --- INTEL NEST (T14 Gen 2 Support) ---
    intel = {
      enable = lib.mkEnableOption "Intel CPU/GPU Support";
    };
  };

  config = lib.mkMerge [
    # 1. AMD P-State Logic
    (lib.mkIf (cfg.amd.enable && cfg.amd.pstate) {
      boot.kernelParams = [ "amd_pstate=active" ];
      hardware.cpu.amd.updateMicrocode = true;
    })

    # 2. Nvidia Driver Selection logic (Phanes Parity)
    (lib.mkIf cfg.nvidia.enable {
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia = {
        # Switches package based on the 'beta' toggle
        package = if cfg.nvidia.beta 
                  then config.boot.kernelPackages.nvidiaPackages.beta 
                  else config.boot.kernelPackages.nvidiaPackages.stable;
        
        open = cfg.nvidia.open;
        modesetting.enable = true;
        powerManagement.enable = lib.mkDefault true;
      };
    })

    # 3. Graphics Foundation
    (lib.mkIf (cfg.amd.enable || cfg.nvidia.enable || cfg.intel.enable) {
      myFeatures.hardware.graphics.enable = true; # Triggers graphics.nix
    })
  ];
}
