{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.core.security;
in
{
  options.myFeatures.core.security = {
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
      unprivilegedUsernsClone = false; 
      
      sudo.execWheelOnly = true;
      auditd.enable = true;
      audit.enable = true;
    };

    # 3. Systemd OOMD
    systemd.oomd.enable = cfg.useOOMD;

    # 4. Glibc & Memory Allocator Hardening
    environment.variables.MALLOC_CHECK_ = "1";

    # 5. Network Privacy: DNS-over-TLS (Structured Settings Refactor)
    services.resolved = {
      enable = true;
      # FIX: Use the specific Resolve sub-attribute set as indicated by warnings
      settings.Resolve = {
        DNSSEC = "true";
        DNSOverTLS = "opportunistic";
        Domains = "~.";
        FallbackDNS = "1.1.1.1 9.9.9.9";
      };
    };

    networking.firewall.enable = lib.mkDefault true;
  };
}
