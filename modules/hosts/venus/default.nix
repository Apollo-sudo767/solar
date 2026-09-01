{
  meta = {
    system = "x86_64-linux";
    stable = false;
    useSecrets = false;
  };

  module =
    { ... }:
    {
      imports = [
        ./hardware-configuration.nix
      ];

      system.stateVersion = "26.11";

      myFeatures = {
        # 🌲 Dendritic Suites
        suites.server.enable = true;

        # 🎛️ Host Specifics
        core = {
          system = {
            core-branch.enable = true;
            disko.enable = false;
            users = {
              usernames = [ "apollo" ];
              agenixPassword = false;
            };
          };
          boot = {
            enable = true;
            secureBoot.enable = true;
          };
          security = {
            security.useAppArmor = true;
            agenix.enable = false;
          };
        };

        hardware.cpu-gpu.amd.enable = true;

        programs.utilities.lego.enable = true;

        services = {
          nginx.enable = true;
          networking.ddns = {
            enable = true;
            domains = [
              "nomansland.apollan.cc"
              "factorio.apollan.cc"
              "joplin.apollan.cc"
              "zotero.apollan.cc"
              "languagetool.apollan.cc"
            ];
          };
          servers = {
            joplin = {
              enable = true;
              baseUrl = "https://joplin.apollan.cc";
            };
            zotero = {
              enable = true;
              baseUrl = "https://zotero.apollan.cc";
              username = "unbalance";
              passwordHash = "{bcrypt}$2b$05$vdB4P/hY/tXngTOBHxuzOun7Mm.dOISAy139getu7z5MWUdofMZru";
            };
            languagetool = {
              enable = true;
              baseUrl = "https://languagetool.apollan.cc";
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
              no-mans-land = {
                enable = true;
                port = 19132;
                voicePort = 24454;
              };
            };
          };
        };
      };
    };
}
