{ config, lib, ... }:

{
  options.services.zfs.snapshot = {
    enable = lib.mkEnableOption "ZFS automatic snapshot retention";
  };

  config = lib.mkIf (config.services.zfs.snapshot.enable or false) {
    services.zfs.autoSnapshot.enable = true;
  };
}
