{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.platforms.styling.flavors.forest;
in
{
  options.myFeatures.platforms.styling.flavors.forest = {
    enable = lib.mkEnableOption "Apollo's Forest Flavor (Universal across compositors & shells)";
  };

  config = lib.mkIf cfg.enable {
    myFeatures.platforms = {
      # 1. Base Theme (Stylix / Colors)
      styling.themes.forest.enable = true;

      # 2. Compositor / Window Manager Styling
      desktops.niri = {
        enable = lib.mkDefault true;
        settings = {
          layout = {
            default-column-width = lib.mkDefault { proportion = 0.5; };
            background-color = "transparent";
            gaps = 6;
            focus-ring.off = { };
            border = {
              width = 2;
              active-color = if config.stylix.enable then "#${config.lib.stylix.colors.base0D}" else "#81a1c1";
              inactive-color = if config.stylix.enable then "#${config.lib.stylix.colors.base02}" else "#434c5e";
            };
          };
          _children = [
            {
              window-rule._children = [
                { geometry-corner-radius = 8.0; }
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
