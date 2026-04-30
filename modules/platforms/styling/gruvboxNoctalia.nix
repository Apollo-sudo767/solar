{ config, lib, ... }:

let
  cfg = config.myFeatures.platforms.styling.gruvboxNoctalia;
  stylixEnabled = config.myFeatures.platfroms.styling.stylix.enable;
  inherit (config.myFeatures.core.system.users) usernames;
in
{
  options.myFeatures.platforms.styling.gruvboxNoctalia.enable =
    lib.mkEnableOption "Apollo's Gruvbox Noctalia Rice";

  config = lib.mkIf cfg.enable {
    myFeatures.platforms = {
      addons.noctalia-shell.enable = true;
      styling.themes.gruvbox.enable = true;
      styling.noctaliaDefaults.enable = true;
    };

    home-manager.users = lib.genAttrs usernames (_name: {
      # Noctalia settings for the rice
      programs.noctalia-shell = {
        settings = {
          colors = lib.mkIf stylixEnabled {
            # Map Stylix colors to Noctalia format
            # Noctalia uses "mPrimary", "mOnPrimary", etc. (Material-ish)
            mPrimary = "#${config.lib.stylix.colors.base0D}";
            mOnPrimary = "#${config.lib.stylix.colors.base00}";
            mSecondary = "#${config.lib.stylix.colors.base0E}";
            mOnSecondary = "#${config.lib.stylix.colors.base00}";
            mSurface = "#${config.lib.stylix.colors.base00}";
            mOnSurface = "#${config.lib.stylix.colors.base05}";
            mBackground = "#${config.lib.stylix.colors.base00}";
            mOnBackground = "#${config.lib.stylix.colors.base05}";
            mOutline = "#${config.lib.stylix.colors.base03}";
          };
        };
      };
    });
  };
}
