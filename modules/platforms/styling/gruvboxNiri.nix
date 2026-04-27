{ config, lib, ... }:

let
  cfg = config.myFeatures.platforms.styling.gruvboxNiri;
in
{
  options.myFeatures.platforms.styling.gruvboxNiri.enable =
    lib.mkEnableOption "Apollo's Gruvbox Niri Rice";

  config = lib.mkIf cfg.enable {
    myFeatures.platforms = {
      desktops.niri.enable = true;
      addons.waybar.enable = true;
      addons.swaybg.enable = true;
      addons.idle.enable = true;
      styling.themes.gruvbox.enable = true;
      styling.niriKeybinds.enable = true;
      addons.fuzzel.enable = true;
      addons.swaylock.enable = true;
    };

    # Simplify the user generation logic
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (name: {
      programs.niri.settings = {
        layout = {
          gaps = 0;
          focus-ring = {
            enable = true;
            width = 2;
            # These only evaluate correctly once Stylix is enabled
            active.color = "#${config.lib.stylix.colors.base0D}";
            inactive.color = "#${config.lib.stylix.colors.base02}";
          };
          border.enable = false;
        };
      };
    });
  };
}
