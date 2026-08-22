{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.platforms.styling.gruvboxNiri;
in
{
  options.myFeatures.platforms.styling.gruvboxNiri.enable =
    lib.mkEnableOption "Apollo's Gruvbox Niri Rice";

  config = lib.mkIf cfg.enable {
    myFeatures.platforms = {
      desktops.niri = {
        enable = true;
        settings.layout = {
          default-column-width = lib.mkDefault { proportion = 0.5; };
          background-color = "transparent";
          gaps = 0;
          focus-ring.off = { };
          border.off = lib.mkForce { };
        };
      };
      addons = {
        # noctalia-shell.enable = false;
        #idle.enable = true;
        #fuzzel.enable = true;
        #swaylock.enable = true;
        #swaybg.enable = lib.mkForce false;
      };
      styling.themes.gruvbox.enable = true;
      styling.niriKeybinds.enable = true;
    };
  };
}
