# modules/core/system/preservation.nix
# ============================================================================
# Ephemeral Root State Preservation (`WilliButz/preservation`)
# ============================================================================
# When `myFeatures.core.system.core-branch.usePersistence = true;` is set on a
# Linux host, the root filesystem (`/`) is a `tmpfs` RAM disk that resets on
# every reboot. This module configures `preservation` to bind-mount or symlink
# essential system state (`/var/log`, `/var/lib/nixos`, `/etc/machine-id`, etc.)
# from `/persist` (NVMe speed pool) and optionally `/persist/bulk` (HDD cold pool).
# Individual feature modules register their own directories/files into
# `preservation.preserveAt.${persistentPath}`.
{
  config,
  lib,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.core.system.preservation;
in
{
  options.myFeatures.core.system.preservation = {
    enable = lib.mkEnableOption "Wipe-on-Boot Preservation";
    persistentPath = lib.mkOption {
      type = lib.types.str;
      default = "/persist";
      description = "The root path for persistent storage (Speed/NVMe).";
    };

    coldPath = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default =
        let
          bulkDisks = config.myFeatures.core.system.disko.bulkDisks or [ ];
        in
        if bulkDisks != [ ] then
          "/persist/bulk"
        else
          config.myFeatures.core.system.preservation.persistentPath;
      description = "The path for cold storage/archives (HDD). Falls back to persistentPath if no HDDs.";
    };
  };

  config = lib.mkIf (cfg.enable && !isDarwin && isTotal) {
    preservation = {
      enable = true;

      # Primary Speed Pool (NVMe/SSD)
      preserveAt = {
        "${cfg.persistentPath}" = {
          directories = [
            "/var/log"
            "/var/lib/nixos"
            "/var/lib/systemd" # Stores backlight, rfkill, timesync, and timer timestamps
          ];
          files = [
            {
              file = "/etc/machine-id";
              how = "symlink";
            }
            {
              file = "/etc/user-password";
              how = "symlink";
            }
          ];
        };
      }
      // lib.optionalAttrs (cfg.coldPath != cfg.persistentPath) {
        # Cold Tier (HDD) - Only merged if a distinct bulk storage pool exists
        "${cfg.coldPath}" = {
          directories = [ ];
        };
      };
    };
  };
}
