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
      # This triggers the automatic theme preset
      styling.gruvbox.enable = true;
      styling.niriKeybinds.enable = true;
      addons.fuzzel.enable = true;
      addons.swaylock.enable = true;
    };

    home-manager.users =
      let
        userList = lib.filter (n: n != "enable" && n != "usernames") config.myFeatures.core.system.users.usernames;
      in
      lib.genAttrs userList (name: {
        programs.niri.settings = {
          layout = {
            gaps = 0;
            focus-ring = {
              enable = true;
              width = 2;
              # AUTOMATIC: Pulls from Stylix colors
              active.color = "#${config.lib.stylix.colors.base0D}";
              inactive.color = "#${config.lib.stylix.colors.base02}";
            };
            border.enable = false;
          };
        };
      });
  };
}
