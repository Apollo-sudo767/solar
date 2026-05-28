{
  meta = {
    system = "x86_64-linux";
    stable = false;
  };

  module =
    { pkgs, lib, ... }:
    {
      imports = [
        ./hardware-configuration.nix
      ];

      system.stateVersion = "26.05";

      myFeatures = {
        core = {
          system.core-branch.enable = true;
          system.users.usernames = [
            "apollo"
            "mcadmin"
          ];
          shell.shell-branch.enable = true;
          boot = {
            enable = true;
            secureBoot.enable = true;
          };
          security.security = {
            enable = true;
            useAppArmor = true;
          };
          nix.lix.enable = true;
        };
        hardware = {
          cpu-gpu.amd.enable = true;
        };
        programs = {
          terminal = {
            ghostty.enable = true;
            fastfetch.enable = true;
            helix.enable = true;
          };
        };
        services = {
          nginx.enable = true;
          hardware.udisks2.enable = true;
          networking = {
            enable = true;
            tailscale.enable = true;
            ddns = {
              enable = true;
              domains = [
                "anytype.apollan.cc"
                "sllv.apollan.cc"
                "create-aero.apollan.cc"
                "factorio.apollan.cc"
                "terraria.apollan.cc"
              ];
            };
          };
          servers = {
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
              create-aero = {
                enable = true;
                port = 19132;
              };
            };
          };
        };
      };

      # Server User Configuration for friends
      users.users.mcadmin = {
        description = "Minecraft Server Admin";
        extraGroups = lib.mkForce [
          "minecraft"
          "networkmanager"
        ];
      };

      # Ensure /srv/minecraft is accessible to the mcadmin user via the minecraft group
      systemd.tmpfiles.rules = [
        "d /srv/minecraft 0775 minecraft minecraft - -"
      ];
    };
}
