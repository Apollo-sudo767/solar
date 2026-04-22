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
      servers = {
        # Set host-specific ports here
        factorio = {
          enable = true;
          port = 34197; 
        };
        terraria = {
          enable = true;
          worldSize = "large";
        };
        minecraft = {
          sllv = {
            enable = true;
            port = 25565;
          };
          # vanilla = {
          #   enable = true;
          #   # (Uses default 25565 if not defined in module)
          # };
        };
      };
      ddns = {
        enable = true;
        domains = [
          "sllv.apollan.cc"
          "survival.apollan.cc"
          "factorio.apollan.cc"
          "anytype.apollan.cc"
        ];
      };
    };
  };
}
