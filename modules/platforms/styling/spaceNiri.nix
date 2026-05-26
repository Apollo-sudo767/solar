{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.platforms.styling.spaceNiri;
in
{
  options.myFeatures.platforms.styling.spaceNiri.enable =
    lib.mkEnableOption "Apollo's Space Niri Rice (Centralized)";

  config = lib.mkIf cfg.enable {
    myFeatures.platforms = {
      # Enable the Space Theme (Stylix settings)
      styling.themes.space.enable = true;

      # Enable all the addons for this rice
      addons = {
        ironbar.enable = true;
        swaync.enable = true;
        swayosd.enable = true;
        swww.enable = true;
        fuzzel.enable = true;
        swaylock.enable = true;
        waybar.enable = lib.mkForce false;
        swaybg.enable = lib.mkForce false;
      };

      # Enable Niri and Keybinds
      desktops.niri.enable = true;
      styling.niriKeybinds.enable = true;
    };

    # Niri-specific aesthetic tweaks for the "Space" look
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      programs.niri.settings = {
        prefer-no-csd = true;
        layout = {
          gaps = 0;
          focus-ring.enable = false;
          border.enable = false;
        };
      };
    });

    # Ensure swww handles wallpaper instead of stylix's default swaybg
    stylix.targets.swaybg.enable = false;
  };
}
