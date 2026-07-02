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

  config = lib.mkIf (cfg.enable && !isDarwin) {
    # Initialize the preservation config
    preservation = {
      enable = true;

      # Primary Speed Pool (NVMe/SSD)
      preserveAt = {
        "${cfg.persistentPath}" = {
          directories = [
            "/var/log"
            "/var/lib/nixos"
            "/var/lib/systemd" # Stores backlight, rfkill, timesync, etc.
          ];
          files = [
            {
              file = "/etc/machine-id";
              how = "symlink";
            }
          ];
        };
      }
      // lib.optionalAttrs (cfg.coldPath != cfg.persistentPath) {
        # Cold Tier (HDD) - Only merged if a distinct bulk storage path exists
        "${cfg.coldPath}" = {
          directories = [ ];
        };
      };
    };
  };
}
