# modules/core/security/security.nix
# ============================================================================
# System Security Hardening, AppArmor, Sudo & Firewall Baseline
# ============================================================================
# Configures kernel page-table isolation, hibernated kernel image protection,
# wheel-only `sudo`, optional AppArmor Mandatory Access Control profiles,
# optional `systemd-oomd` out-of-memory protection, and enables the NixOS
# stateful firewall by default (`networking.firewall.enable = lib.mkDefault true`).
{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.core.security.security;
in
{
  options.myFeatures.core.security.security = {
    enable = lib.mkEnableOption "General System Security Hardening";
    useAppArmor = lib.mkEnableOption "AppArmor MAC support";
    useOOMD = lib.mkEnableOption "Systemd-OOMD stability";
  };

  config = lib.mkIf (cfg.enable && isTotal) (
    lib.optionalAttrs (!isDarwin) {
      security = {
        # 1. AppArmor Mandatory Access Control (MAC)
        apparmor = lib.mkIf cfg.useAppArmor {
          enable = true;
          enableCache = true;
          killUnconfinedConfinables = true;
          packages = with pkgs; [
            apparmor-profiles
            apparmor-utils
          ];
        };

        # 2. Kernel & User-Space Hardening
        forcePageTableIsolation = true;
        protectKernelImage = true;

        sudo = {
          execWheelOnly = true;
          extraConfig = ''
            Defaults lecture=never
          '';
        };
      };

      # 3. Systemd Out-Of-Memory Daemon (OOMD)
      systemd.oomd.enable = cfg.useOOMD;

      # 4. Enable stateful firewall by default on all hardened Linux hosts
      networking.firewall.enable = lib.mkDefault true;
    }
  );
}
