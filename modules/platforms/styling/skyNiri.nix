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
      desktops.niri = {
        enable = true;
        settings = {
          layout = {
            default-column-width = lib.mkDefault { proportion = 0.5; };
            background-color = "transparent";
            gaps = 8;
            focus-ring.off = { };
            border = {
              width = 2;
              active-color = if config.stylix.enable then "#${config.lib.stylix.colors.base0D}" else "#83a598";
              inactive-color = if config.stylix.enable then "#${config.lib.stylix.colors.base02}" else "#504945";
            };
          };
          _children = [
            {
              window-rule._children = [
                { geometry-corner-radius = 10.0; }
                { clip-to-geometry = true; }
              ];
            }
          ];
        };
      };
      styling.niriKeybinds.enable = true;

      # Use the NEW Noctalia v5 Rice instead of defaults
      styling.skyNoctalia.enable = true;
    };
  };
}
