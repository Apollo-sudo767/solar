# modules/programs/terminal/ghostty.nix
# ============================================================================
# Ghostty GPU-Accelerated Terminal Emulator
# ============================================================================
# Configures Ghostty via Home Manager with Zsh shell integration, translucent
# blurred background, and automatic window decoration toggling (enabled on
# floating desktop environments like KDE/GNOME/COSMIC, disabled on Niri).
{
  config,
  lib,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.programs.terminal.ghostty;

  isDE =
    (config.myFeatures.platforms.desktops.kde.enable or false)
    || (config.myFeatures.platforms.desktops.gnome.enable or false)
    || (config.myFeatures.platforms.desktops.cosmic.enable or false);

  isTiling = config.myFeatures.platforms.desktops.niri.enable or false;
in
{
  options.myFeatures.programs.terminal.ghostty.enable =
    lib.mkEnableOption "Ghostty Terminal Emulator";

  config = lib.mkIf cfg.enable {
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
