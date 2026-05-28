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

    # FIX: Only map over the list of strings in .usernames
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      stylix.targets.ghostty.enable = true;
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
    });
  };
}
