# modules/platforms/styling/flavors/gruvbox.nix
# ============================================================================
# Gruvbox Desktop Flavor
# ============================================================================
# Applies the Gruvbox Base16 color palette and configures Niri with a minimal,
# gapless, borderless layout and standard keybindings.
{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.platforms.styling.flavors.gruvbox;
in
{
  options.myFeatures.platforms.styling.flavors.gruvbox = {
    enable = lib.mkEnableOption "Apollo's Gruvbox Flavor (Universal across compositors & shells)";
  };

  config = lib.mkIf cfg.enable {
    myFeatures.platforms = {
      # 1. Base Theme (Stylix / Colors)
      styling.themes.gruvbox.enable = true;

      # 2. Compositor / Window Manager Styling (Gruvbox uses a minimal gapless, borderless layout)
      desktops.niri = {
        enable = lib.mkDefault true;
        gaps = lib.mkDefault 0;
        settings.layout.border.off = lib.mkForce { };
      };

      styling.niriKeybinds.enable = lib.mkDefault true;
    };
  };
}
