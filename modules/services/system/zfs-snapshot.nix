# modules/services/system/zfs-snapshot.nix
# ============================================================================
# ZFS Automatic Snapshot Retention Service
# ============================================================================
# Enables NixOS `services.zfs.autoSnapshot` for rolling frequent, hourly,
# daily, weekly, and monthly ZFS dataset snapshots on storage hosts (e.g. `sol`).
{ config, lib, ... }:

let
  cfg = config.myFeatures.services.system.zfs-snapshot;
in
{
  options.myFeatures.services.system.zfs-snapshot = {
    enable = lib.mkEnableOption "ZFS automatic snapshot retention";
  };

  config = lib.mkIf cfg.enable {
    services.zfs.autoSnapshot.enable = true;
  };
}
