{ lib, inputs, ... }:

{

  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "venus";
  system.stateVersion = "26.05";

  myFeatures = {
    core.enable = true;
    shell.enable = true;
    core.secureboot.enable = true;
    core.security = {
      enable = true;
      useAppArmor = true;
    };
    core.sops.enable = true;
    hardware = {
      amd.enable = true;
      bluetooth.enable = true;
      wifi.enable = true;
    };
    systems = {
      presets.gruvboxNiri.enable = true;
      displayManager.manager = "tuigreet";
    };
    programs = {
      ghostty.enable = true;
      gaming.enable = true;
      firefox.enable = true;
      fastfetch.enable = true;
      helix.enable = true;
      media.enable = true;
      social.enable = true;
      obs.enable = true;
      stylePackages.enable = true;
      bitwarden.enable = true;
      davinci.enable = true;
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
