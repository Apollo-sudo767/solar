# modules/platforms/styling/flavors/strawberry.nix
# ============================================================================
# Strawberry Desktop Flavor
# ============================================================================
# Combines the light-polarity Strawberry Stylix color scheme with Niri and
# default keybindings.
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
      # Base layout, borders, and rounded corners are handled by `niri/layout.nix`
      # and `stylix-bridge/niri.nix`.
      desktops.niri.enable = lib.mkDefault true;
      styling.niriKeybinds.enable = lib.mkDefault true;
    };
  };
}
