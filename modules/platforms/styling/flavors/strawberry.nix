{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.platforms.styling.flavors.strawberry;
in
{
  options.myFeatures.platforms.styling.flavors.strawberry = {
    enable = lib.mkEnableOption "Apollo's Strawberry Flavor (Universal across compositors & shells)";
  };

  config = lib.mkIf cfg.enable {
    myFeatures.platforms = {
      # 1. Base Theme (Stylix / Colors)
      styling.themes.strawberry.enable = true;

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
              active-color = if config.stylix.enable then "#${config.lib.stylix.colors.base0D}" else "#c1121f";
              inactive-color = if config.stylix.enable then "#${config.lib.stylix.colors.base02}" else "#ffd1da";
            };
          };
          _children = [
            {
              window-rule._children = [
                { geometry-corner-radius = 12.0; }
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
