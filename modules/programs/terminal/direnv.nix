{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:
let
  cfg = config.myFeatures.programs.terminal.direnv;
in
{
  options.myFeatures.programs.terminal.direnv.enable =
    lib.mkEnableOption "direnv and nix-direnv auto-environment loader";

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
      }
    ];
  };
}
