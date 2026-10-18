{ config, lib, ... }:

let
  cfg = config.myFeatures.services.system.zfs-snapshot;
  legacyCfg = config.services.zfs.snapshot.enable or false;
  enabled = cfg.enable || legacyCfg;
in
{
  options.myFeatures.services.system.zfs-snapshot = {
    enable = lib.mkEnableOption "ZFS automatic snapshot retention";
  };

  # Backward compatibility alias
  options.services.zfs.snapshot = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Deprecated: use myFeatures.services.system.zfs-snapshot.enable instead.";
    };
  };

  config = lib.mkIf enabled {
    services.zfs.autoSnapshot.enable = true;
  };
}
