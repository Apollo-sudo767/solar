{ lib, inputs, ... }:

{

  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "sol";
  system.stateVersion = "26.05";

  myFeatures = {
    core.enable = true;
    shell.enable = true;
    hardware = {
      amd.enable = true;
      nvidia.enable = false;
      bluetooth.enable = true;
    };
    systems = {
      presets.gruvboxNiri.enable = true;
      displayManager.manager = "tuigreet";
    };
    programs = {
      ghostty.enable = true;
      gaming.enable = true;
      firefox.enable = true;
      zen.enable = true;
      fastfetch.enable = true;
    };
    services = {
      audio.enable = true;
      flatpak.enable = true;
      printing.enable = true;
      xdgPortals.enable = true;
      udisks2.enable = true;
    };
  };
}
