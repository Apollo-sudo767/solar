{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.platforms.styling.skyNoctalia;
  inherit (config.myFeatures.core.system.users) usernames;
  stylixEnabled = config.myFeatures.platforms.styling.stylix.enable;
in
{
  options.myFeatures.platforms.styling.skyNoctalia.enable =
    lib.mkEnableOption "Apollo's Sky Noctalia v5 Rice";

  config = lib.mkIf cfg.enable {
    myFeatures.platforms.addons.noctalia-v5.enable = true;

    home-manager.users = lib.genAttrs usernames (_name: {
      programs.noctalia = {
        settings = {
          # v5 Specific Configuration
          bar = {
            enable = true;
            position = "top";
            height = 36;
          };

          # Material Design-ish Colors (v5)
          colors = lib.mkIf stylixEnabled {
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
