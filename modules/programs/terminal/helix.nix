{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  usernames = config.myFeatures.core.system.users.usernames;
in
{
  options.myFeatures.programs.terminal.helix.enable = lib.mkEnableOption "Helix Editor";

  config = lib.mkIf config.myFeatures.programs.terminal.helix.enable {

    # 1. Ensure the LSP and formatter binaries are actually installed on the system
    environment.systemPackages = with pkgs; [
      nixd
      nixfmt
    ];

    home-manager.users = lib.genAttrs usernames (name: {
      programs.helix = {
        enable = true;

        # Your existing settings
        settings = {
          theme = lib.mkForce "gruvbox";
          editor = {
            line-number = "relative";
            cursor-shape = {
              insert = "bar";
              normal = "block";
            };
          };
        };

        # 2. Wire up the Language Server
        languages = {
          language-server.nixd = {
            # lib.getExe safely points directly to the binary in the nix store
            command = lib.getExe pkgs.nixd;
          };

          language = [
            {
              name = "nix";
              auto-format = true;
              formatter.command = lib.getExe pkgs.nixfmt;
              language-servers = [ "nixd" ];
            }
          ];
        };

      };
    });
  };
}
