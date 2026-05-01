{
  meta = {
    system = "x86_64-linux";
    stable = false;
  };

  module =
    { ... }:
    {
      imports = [
        ./hardware-configuration.nix
      ];

      system.stateVersion = "26.05";

      myFeatures = {
        core = {
          system.core-branch.enable = true;
          shell.shell-branch.enable = true;
          boot.secureboot.enable = true;
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
                "darkrpg.apollan.cc"
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
    };
}
