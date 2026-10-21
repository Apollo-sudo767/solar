# modules/hosts/phobos/default.nix
# ==============================================================================
# Host Configuration — Phobos (Apple Silicon macOS Workstation)
# ==============================================================================
# `aarch64-darwin` workstation managed via nix-darwin + Home Manager, featuring
# `suites.darwinWorkstation`, AeroSpace tiling WM, and Sky Stylix theming.
# ==============================================================================

{
  meta = {
    system = "aarch64-darwin";
    stable = false;
  };

  module = _: {
    system.stateVersion = 5;
    system.primaryUser = "apollo";

    myFeatures = {
      # 🌲 Dendritic Suites
      suites.darwinWorkstation.enable = true;

      # 🎛️ Host & Darwin Specifics
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
        security.agenix.enable = false;
      };

      programs = {
        terminal.nh.enable = true;
        utilities.logseq.enable = true;
      };

      platforms.styling = {
        stylix.enable = true;
        themes.sky.enable = true;
      };

      services.networking.tailscale.enable = true;
    };
  };
}
