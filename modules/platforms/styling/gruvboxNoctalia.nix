{ config, lib, ... }:

let
  cfg = config.myFeatures.platforms.styling.gruvboxNoctalia;
in
{
  options.myFeatures.platforms.styling.gruvboxNoctalia.enable =
    lib.mkEnableOption "Apollo's Gruvbox Noctalia Rice";

  config = lib.mkIf cfg.enable {
    myFeatures.platforms = {
      addons.noctalia-shell.enable = true;
      styling.themes.gruvbox.enable = true;
    };

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      # Noctalia settings for the rice
      programs.noctalia-shell = {
        # Any specific rice settings would go here
      };
    });
  };
}
