# modules/platforms/styling/flavors/sky.nix
# ============================================================================
# Sky Desktop Flavor
# ============================================================================
# Combines the Sky Stylix color scheme with Niri, default keybindings, and the
# custom Sky Noctalia v5 shell rice (`skyNoctalia`).
{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.platforms.styling.flavors.sky;
in
{
  options.myFeatures.platforms.styling.flavors.sky = {
    enable = lib.mkEnableOption "Apollo's Sky Flavor (Universal across compositors & shells)";
  };

  config = lib.mkIf cfg.enable {
    myFeatures.platforms = {
      # 1. Base Theme (Stylix / Colors)
      styling.themes.sky.enable = true;

      # 2. Compositor / Window Manager Styling
      # Base layout, borders, and rounded corners are handled by `niri/layout.nix`
      # and `stylix-bridge/niri.nix`.
      desktops.niri.enable = lib.mkDefault true;
      styling.niriKeybinds.enable = lib.mkDefault true;

      # 3. Addon / Shell Integration
      styling.skyNoctalia.enable = lib.mkDefault true;
    };
  };
}
