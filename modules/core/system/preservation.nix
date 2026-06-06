{
  config,
  lib,
  isDarwin,
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
      description = "The root path for persistent storage.";
    };
    bulkPath = lib.mkOption {
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
      description = "The path for bulk storage (falls back to persistentPath if no bulk disks).";
    };
  };

  config = lib.mkIf (cfg.enable && !isDarwin) {
    # Initialize the preservation config
    preservation = {
      enable = true;

      # Primary Speed Pool (NVMe/SSD)
      preserveAt."${cfg.persistentPath}" = {
        directories = [
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
        ];
      };

      # Bulk Tier
      preserveAt."${cfg.bulkPath}" = {
        directories = [ ];
      };
    };
  };
}
