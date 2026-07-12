{
  # NO FUNCTION WRAPPER AT THE TOP.
  # This makes 'meta' a top-level attribute that 'import' can see instantly.
  meta = {
    system = "aarch64-darwin";
    stable = false;
  };

  module = _: {
    system.stateVersion = 5;

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
          # Ensure agenix stays explicitly disabled for this host so it ignores secrets
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
          antigravity.enable = true;
          nh.enable = true;
          direnv.enable = true;
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
      services = {
        networking = {
          tailscale.enable = true;
          syncthing.enable = true;
        };
        servers = {
          trilium = {
            enable = true;
            type = "desktop";
          };
        };
      };
    };
  };
}
