{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.programs.ghostty;
in
{
  options.myFeatures.programs.ghostty.enable = lib.mkEnableOption "Ghostty Terminal Emulator";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.ghostty ];

    # FIX: Only map over the list of strings in .usernames
    home-manager.users = lib.genAttrs config.myFeatures.core.users.usernames (name: {
      programs.ghostty = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          theme = "Gruvbox Dark";
          font-size = 12;
          font-family = "JetBrainsMono Nerd Font";
          window-padding-x = 10;
          window-padding-y = 10;
          window-decoration = false;
          confirm-close-surface = false;
        };
      };
    });
  };
}
