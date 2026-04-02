{ lib, inputs, ...}: {
  imports = [
    ./hardware.nix
    ../shared/disko-standard.nix
  ];

  networking.hostName = "mercury";
  system.stateVersion = "26.05";

  myFeatures = {
    core = {
      enable = true;
      persistence.enable = true;
      secureboot.enable = true;
      persistentUsers.enable = true;
    };
    shell.enable = true;

    hardware = {
      graphics.enable = true;
      battery = {
        enable = true;
        fullCharge = true;
        bluetooth.enable = true;
        aggressive = true;
      };
      bluetooth.enable = true;
      controllers.enable = true;
      trackpad.enable = true;
      wifi.enable = true;
    };

    systems = {
      presets.gruvboxNiri.enable = true;
      displayManager.manager = "tuigreet";
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
    };
  };
}
