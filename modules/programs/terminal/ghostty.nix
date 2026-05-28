{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  inherit isTotal;
  cfg = config.myFeatures.programs.terminal.ghostty;
in
{
  options.myFeatures.programs.terminal.ghostty.enable =
    lib.mkEnableOption "Ghostty Terminal Emulator";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.ghostty ];

    home-manager.sharedModules = [
      {
        programs.ghostty = {
          enable = true;
          enableZshIntegration = true;
          settings = {
            theme = lib.mkDefault "Gruvbox Dark";
            font-size = lib.mkDefault 12;
            font-family = lib.mkDefault "JetBrainsMono Nerd Font";
            window-padding-x = 10;
            window-padding-y = 10;
            window-decoration = false;
            confirm-close-surface = false;
          };
        };
      }
    ];
  };
}
