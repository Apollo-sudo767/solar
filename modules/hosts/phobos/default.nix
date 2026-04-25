{
  # NO FUNCTION WRAPPER AT THE TOP.
  # This makes 'meta' a top-level attribute that 'import' can see instantly.
  meta = {
    system = "aarch64-darwin";
    stable = false;
  };

  module =
    { pkgs, lib, ... }:
    {
      system.stateVersion = 5;
      system.primaryUser = "apollo";

      myFeatures = {
        core = {
          enable = true;
          lix.enable = true;
          nix-settings.enable = true;
          ssh.enable = true;
          users = {
            enable = true;
            usernames = [ "apollo" ];
          };
        };
        darwin = {
          core.enable = true;
          homebrew.enable = true;
        };
        shell.enable = true;
        programs = {
          fastfetch.enable = true;
          helix.enable = true;
        };
        systems = {
          stylix = {
            enable = true;
            gruvbox.enable = true;
          };
        };
        services.networking.tailscale.enable = true;
      };
    };
}
