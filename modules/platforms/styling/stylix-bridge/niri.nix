# modules/platforms/styling/stylix-bridge/niri.nix
# ============================================================================
# Stylix Bridge for Niri Compositor
# ============================================================================
# Propagates Stylix cursor theme/size, Base16 window border/focus-ring colors,
# and fallback `swaybg` wallpaper management (when Noctalia v5 is not active)
# into Niri's KDL settings.
{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.niri;
  stylixEnabled = config.myFeatures.platforms.styling.stylix.enable or false;
  c = config.lib.stylix.colors;
in
{
  config = lib.mkIf (cfg.enable && stylixEnabled) {
    myFeatures.platforms.desktops.niri.settings = {
      # 1. Cursor styling
      cursor = lib.mkIf (config.stylix.cursor != null) {
        xcursor-theme = config.stylix.cursor.name;
        xcursor-size = config.stylix.cursor.size;
      };

      # 2. Environment variables for cursor inheritance across Wayland and Xwayland
      environment = lib.mkIf (config.stylix.cursor != null) {
        XCURSOR_THEME = config.stylix.cursor.name;
        XCURSOR_SIZE = toString config.stylix.cursor.size;
      };

      # 3. Dynamic Stylix layout palette
      layout = {
        border = {
          active-color = lib.mkDefault "#${c.base0D}";
          inactive-color = lib.mkDefault "#${c.base02}";
        };
        focus-ring = {
          active-color = lib.mkDefault "#${c.base0D}";
          inactive-color = lib.mkDefault "#${c.base02}";
        };
        tab-indicator = {
          active-color = lib.mkDefault "#${c.base0D}";
          inactive-color = lib.mkDefault "#${c.base02}";
        };
      };
    };

    # 4. If Noctalia v5 is not managing the desktop wallpaper, ensure swaybg service is enabled with the Stylix wallpaper
    myFeatures.platforms.addons.swaybg.enable = lib.mkIf (
      !config.myFeatures.platforms.addons.noctalia-v5.enable
    ) (lib.mkDefault true);
  };
}
