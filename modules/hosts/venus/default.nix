{ lib, inputs, ... }:

{

  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "venus";
  system.stateVersion = "26.05";

  myFeatures = {
    core.enable = true;
    core.lix.enable = true;
    shell.enable = true;
    core.secureboot.enable = true;
    core.security = {
      enable = true;
      useAppArmor = true;
    };
    hardware = {
      amd.enable = true;
    };
    programs = {
      ghostty.enable = true;
      fastfetch.enable = true;
      helix.enable = true;
    };
    services = {
      udisks2.enable = true;
      networking = {
        enable = true;
        tailscale.enable = true;
      };
      game-servers = {
        minecraft-mca.enable = true;
        minecraft-vanilla.enable = true;
      };
    };
  };
}
