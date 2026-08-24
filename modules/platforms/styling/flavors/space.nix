{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.platforms.styling.flavors.space;
in
{
  options.myFeatures.platforms.styling.flavors.space = {
    enable = lib.mkEnableOption "Apollo's Space Flavor (Universal across compositors & shells)";
  };

  config = lib.mkIf cfg.enable {
    myFeatures.platforms = {
      # 1. Base Theme (Stylix / Colors)
      styling.themes.space.enable = true;

      # 2. Compositor / Window Manager Styling
      desktops.niri = {
        enable = lib.mkDefault true;
        settings = {
          layout = {
            default-column-width = lib.mkDefault { proportion = 0.5; };
            background-color = "transparent";
            gaps = 8;
            focus-ring.off = { };
            border = {
              width = 2;
              active-color = if config.stylix.enable then "#${config.lib.stylix.colors.base0D}" else "#59c2ff";
              inactive-color = if config.stylix.enable then "#${config.lib.stylix.colors.base02}" else "#1e2430";
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

      styling.niriKeybinds.enable = lib.mkDefault true;
    };
  };
}
