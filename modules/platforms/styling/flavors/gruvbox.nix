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

      # 2. Compositor / Window Manager Styling
      desktops.niri = {
        enable = lib.mkDefault true;
        settings.layout = {
          default-column-width = lib.mkDefault { proportion = 0.5; };
          background-color = "transparent";
          gaps = 0;
          focus-ring.off = { };
          border.off = lib.mkForce { };
        };
      };

      styling.niriKeybinds.enable = lib.mkDefault true;

      # 3. Addon / Shell Integration
      addons.noctalia-shell.enable = lib.mkDefault false;
    };
  };
}
