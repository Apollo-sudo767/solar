# modules/platforms/styling/flavors/forest.nix
# ============================================================================
# Forest Desktop Flavor
# ============================================================================
# Combines the Forest (Nord-inspired) Stylix color scheme with Niri and default
# keybindings, setting a slightly tighter 6px window gap.
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
      # Base layout, borders, and rounded corners are handled by `niri/layout.nix`
      # and `stylix-bridge/niri.nix`.
      desktops.niri = {
        enable = lib.mkDefault true;
        gaps = lib.mkDefault 6;
      };

      styling.niriKeybinds.enable = lib.mkDefault true;
    };
  };
}
