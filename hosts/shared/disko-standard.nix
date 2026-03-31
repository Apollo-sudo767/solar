{ lib, imports, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
  ];
  
  disko.devices = {
    disk.main = {
      type = "disk";
      device = lib.mkDefault "/dev/nvme0n1";
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
              mountOptions = [ "umask=0077" ];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";
              # Disko prompts for the password during installation
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/nix"; 
              };
            };
          };
        };
      };
    };
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [ "size=4G" "mode=755" ]; #
    };
  };
}
