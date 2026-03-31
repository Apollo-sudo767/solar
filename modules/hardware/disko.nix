# modules/hardware/disko.nix
{ config, lib, ... }:

let
  cfg = config.myFeatures.hardware.disko;
in
{
  options.myFeatures.hardware.disko = {
    enable = lib.mkEnableOption "Disko";
    mars = lib.mkEnableOption "Mars-specific multi-drive layout";
  };

  config = lib.mkIf cfg.enable {
    disko.devices = {
      disk = {
        # Main OS Drive
        main = {
          device = "/dev/disk/by-uuid/fce8da37-711c-4ca6-b53a-40efb6bbdfab"; #
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "512M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "fmask=0077" "dmask=0077" ]; #
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
        
        # Mars-specific secondary storage
        nvme_extra = lib.mkIf cfg.mars {
          device = "/dev/disk/by-uuid/bd61e42b-16e9-4222-9075-d6318db371ca";
          type = "disk";
          content = { type = "gpt"; partitions.storage = { size = "100%"; content = { type = "filesystem"; format = "ext4"; mountpoint = "/home/nvme"; }; }; };
        };
        ssd_extra = lib.mkIf cfg.mars {
          device = "/dev/disk/by-uuid/4ecb3d2d-85b7-4f08-82a5-e32ff1801100";
          type = "disk";
          content = { type = "gpt"; partitions.storage = { size = "100%"; content = { type = "filesystem"; format = "ext4"; mountpoint = "/home/ssd"; }; }; };
        };
        hdd_extra = lib.mkIf cfg.mars {
          device = "/dev/disk/by-uuid/5ee3390e-5e47-4794-953b-a6cde2a5f955";
          type = "disk";
          content = { type = "gpt"; partitions.storage = { size = "100%"; content = { type = "filesystem"; format = "ext4"; mountpoint = "/home/hdd"; }; }; };
        };
      };
    };
  };
}
