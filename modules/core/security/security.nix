{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.core.security.security;
in
{
  options.myFeatures.core.security.security = {
    enable = lib.mkEnableOption "General System Security Hardening";
    useAppArmor = lib.mkEnableOption "AppArmor MAC support";
    useOOMD = lib.mkEnableOption "Systemd-OOMD stability";
  };

  config = lib.mkIf cfg.enable {
    security = {
      # 1. AppArmor Logic
      apparmor = lib.mkIf cfg.useAppArmor {
        enable = true;
        enableCache = true;
        killUnconfinedConfinables = true;
        packages = with pkgs; [
          apparmor-profiles
          apparmor-utils
        ];
      };

      # 2. Kernel & User-space Hardening
      forcePageTableIsolation = true;
      protectKernelImage = true;
      
      # Disabling unprivileged user namespaces
      unprivilegedUsernsClone = true; 
      
      sudo.execWheelOnly = true;
    };

    # 3. Systemd OOMD
    systemd.oomd.enable = cfg.useOOMD;

    # 4. Glibc & Memory Allocator Hardening
    environment.variables.MALLOC_CHECK_ = "1";


    networking.firewall.enable = lib.mkDefault true;
  };
}
