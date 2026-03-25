{ lib, inputs, ...}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "europa";
  system.stateVersion = "26.05";

  myFeatures = {
    core = {
      enable = true;
      users.usernames = [ "hephaestus" ];
    };
    shell.enable = true;
    hardware = {
      graphics.enable = true;
      battery = {
        enable = true;
        fullCharge = true;
        bluetooth.enable = false;
        aggressive = true;
      };
      bluetooth.enable = true;
      controllers.enable = true;
      trackpad.enable = true;
      wifi.enable = true;
    };
    systems = {
      kde.enable = true;
      displayManager.manager = "sddm";
      stylix.forest.enable = true;
    };
    programs = {
      ghostty.enable = true;
      firefox.enable = true;
      gaming.enable = true;
      fastfetch.enable = true;
      helix.enable = true;
      media.enable = true;
      social.enable = true;
      obs.enable = true;
      bitwarden.enable = true;
      stylePackages.enable = true;
    };
    services = {
      audio.enable = true;
      flatpak.enable = true;
      xdgPortals.enable = true;
      printing.enable = true;
      udisks2.enable = true;
    };
  };
}
