{
  # NO FUNCTION WRAPPER AT THE TOP.
  # This makes 'meta' a top-level attribute that 'import' can see instantly.
  meta = {
    system = "aarch64-darwin";
    stable = false;
  };

  module = _: {
    system.stateVersion = 5;

    age.rekey.hostPubkey = "age1vdk2uqhss7xuacntfx95rkcplluwzx33mcxr66rdhu0sh5a0e5rsffrf34";

    system.primaryUser = "apollo";

    myFeatures = {
      core = {
        system = {
          core-branch = {
            enable = true;
            usePersistence = false;
          };
          disko.enable = false;
          users = {
            enable = true;
            usernames = [ "apollo" ];
          };
        };
        nix = {
          lix.enable = true;
          nix-settings.enable = true;
        };
        security = {
          ssh.enable = true;
          agenix.enable = false;
        };
        shell.shell-branch.enable = true;
      };

      darwin = {
        system = {
          core.enable = true;
          homebrew.enable = true;
        };
      };
      programs = {
        terminal = {
          fastfetch.enable = true;
          helix.enable = true;
          gemini.enable = true;
        };
        utilities = {
          logseq.enable = true;
        };
      };
      platforms = {
        styling = {
          stylix.enable = true;
          themes.sky.enable = true;
        };
      };
      services.networking = {
        tailscale.enable = true;
        syncthing.enable = true;
      };
    };
  };
}
