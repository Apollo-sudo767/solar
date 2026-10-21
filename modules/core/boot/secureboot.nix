# modules/core/boot/secureboot.nix
# ============================================================================
# UEFI Secure Boot via Limine & `sbctl`
# ============================================================================
# Enables native Limine UEFI binary signing and config BLAKE2B checksum
# enrollment during system rebuilds, installs `sbctl` for key management, and
# preserves `/var/lib/sbctl` across reboots on ephemeral-root hosts.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.core.boot;
in
{
  config = lib.mkIf (cfg.enable && cfg.secureBoot.enable) {
    # 1. Enable native Limine Secure Boot signing and config hash enrollment
    boot.loader.limine.secureBoot.enable = true;
    boot.loader.limine.enrollConfig = true;

    # 2. Install Secure Boot key management CLI (`sbctl`)
    environment.systemPackages = [ pkgs.sbctl ];

    # 3. Persist Secure Boot signing keys across reboots on ephemeral root systems
    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf config.myFeatures.core.system.preservation.enable
        {
          directories = [
            {
              directory = "/var/lib/sbctl";
              mode = "0700";
            }
          ];
        };
  };
}
