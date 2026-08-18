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

  isDE =
    (config.myFeatures.platforms.desktops.kde.enable or false)
    || (config.myFeatures.platforms.desktops.gnome.enable or false);

  isTiling =
    (config.myFeatures.platforms.desktops.niri.enable or false)
    || (config.myFeatures.platforms.desktops.paneru.enable or false);
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
            font-size = lib.mkDefault 12;
            font-family = lib.mkDefault "JetBrainsMono Nerd Font";
            window-padding-x = 10;
            window-padding-y = 10;
            window-decoration = lib.mkDefault (if isDE then true else (!isTiling));
            confirm-close-surface = false;
            background-opacity = lib.mkDefault 0.85;
            background-blur = lib.mkDefault true;
            background-blur-radius = lib.mkDefault 20;
          };
        };
      }
    ];
  };
}
