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
        cloudflare = {
          enable = true;
          tunnelId = "17984f9e-b81c-4884-ace1-5347716a0928";
          domains = {
            "sllv.apollan.cc" = "tcp://localhost:25566";
            "survival.apollan.cc" = "tcp://localhost:25565"; # Added missing colon
          };
        };
        tailscale.enable = true;
      };
      game-servers = {
        minecraft-mca.enable = true;
        minecraft-vanilla.enable = true;
      };
    };
  };
}
