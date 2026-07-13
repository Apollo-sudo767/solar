{
  meta = {
    system = "x86_64-linux";
    stable = false;
    useSecrets = false;
  };

  module =
    { pkgs, lib, ... }:
    {
      imports = [
        ./hardware-configuration.nix
      ];

      system.stateVersion = "26.11";

      age.rekey.hostPubkey = "age17au70tcp7jyyl9ln2wgdmef9tpt6ex6jy7qayezp44rsdhzrlqtqmg4ftz";

      myFeatures = {
        core = {
          system.core-branch.enable = true;
          system.users = {
            usernames = [
              "apollo"
            ];
            agenixPassword = false;
          };
          shell.shell-branch.enable = true;
          boot = {
            enable = true;
            secureBoot.enable = true;
          };
          security.security = {
            enable = true;
            useAppArmor = true;
          };
          security.agenix.enable = false;
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
            nh.enable = true;
            direnv.enable = true;
            nix-ld.enable = true;
          };
          utilities.lego.enable = true;
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
                "create-aero.apollan.cc"
                "factorio.apollan.cc"
                "trilium.apollan.cc"
              ];
            };
          };
          servers = {
            trilium = {
              enable = true;
              type = "server";
            };
            factorio = {
              enable = true;
              port = 34197;
            };
            minecraft = {
              admin.enable = true;
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
