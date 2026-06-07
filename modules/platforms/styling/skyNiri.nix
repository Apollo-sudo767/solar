{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.platforms.styling.skyNiri;
in
{
  options.myFeatures.platforms.styling.skyNiri.enable =
    lib.mkEnableOption "Apollo's Sky Niri Rice (Centralized)";

  config = lib.mkIf cfg.enable {
    myFeatures.platforms = {
      # Enable the Sky Theme (Stylix settings)
      styling.themes.sky.enable = true;

      # Enable all the addons for this rice
      addons = {
        # swayosd.enable = true;
        # fuzzel.enable = true;
        # swaylock.enable = true;
        # swaybg.enable = lib.mkForce false;
      };

      # Enable Niri and Keybinds
      desktops.niri.enable = true;
      styling.niriKeybinds.enable = true;

      # Use the NEW Noctalia v5 Rice instead of defaults
      styling.skyNoctalia.enable = true;
    };

    # Niri-specific aesthetic tweaks for the "Sky" look
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      programs.niri.settings = {
        prefer-no-csd = true;
        window-rules = [
          {
            geometry-corner-radius = {
              top-left = 10.0;
              top-right = 10.0;
              bottom-left = 10.0;
              bottom-right = 10.0;
            };
            clip-to-geometry = true;
            focus-ring.enable = false;
          }
        ];
        layout = lib.mkForce {
          gaps = 8;
          focus-ring = {
            enable = false;
            width = 0;
          };
          border = {
            enable = true;
            width = 2;
            active.color = if config.stylix.enable then "#${config.lib.stylix.colors.base0D}" else "#83a598";
            inactive.color = if config.stylix.enable then "#${config.lib.stylix.colors.base02}" else "#504945";
          };
        };
      };
    });

  };
}
