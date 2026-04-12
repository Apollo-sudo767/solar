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
      lix.enable = true;
    };
    shell.enable = true;
    hardware = {
      graphics.enable = true;
      nvidia = {
        enable = true;
        open = false;
        beta = false;
        prime = {
          enable = true;
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };
      };
      battery = {
        enable = true;
        fullCharge = true;
        bluetooth.enable = false;
        aggressive = true;
      };
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
      fastfetch = {
        enable = true;
        showBattery = true;
      };
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
      networking.tailscale.enable = true;
    };
  };
}
