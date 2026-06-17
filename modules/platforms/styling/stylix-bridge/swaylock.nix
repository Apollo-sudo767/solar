{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.swaylock;
  c = config.lib.stylix.colors;
in
{
  config = lib.mkIf (cfg.enable && config.stylix.enable) {
    home-manager.sharedModules = [
      {
        programs.swaylock.settings = lib.mkForce {
          scaling = "fill";
          image = "${config.stylix.image}";

          # Stylix Dynamic Palette
          color = "${c.base00}";
          ring-color = "${c.base0A}";
          key-hl-color = "${c.base08}";

          line-color = "00000000";
          inside-color = "00000000";
          separator-color = "00000000";

          screenshots = true;
          clock = true;
          indicator = true;
          indicator-radius = 100;
          indicator-thickness = 7;
          effect-blur = "7x5";
          effect-vignette = "0.5:0.5";
        };
      }
    ];
  };
}
