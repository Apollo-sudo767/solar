{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  inherit isTotal;
in
{
  options.myFeatures.programs.terminal.helix.enable = lib.mkEnableOption "Helix Editor";

  config = lib.mkIf config.myFeatures.programs.terminal.helix.enable {

    # Ensure the LSP and formatter binaries are actually installed on the system
    environment.systemPackages = with pkgs; [
      nixd
      nixfmt
    ];

    home-manager.sharedModules = [
      {
        programs.helix = {
          enable = true;

          settings = {
            editor = {
              line-number = "relative";
              cursor-shape = {
                insert = "bar";
                normal = "block";
              };
            };
          };

          languages = {
            language-server.nixd = {
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
      }
    ];
  };
}
