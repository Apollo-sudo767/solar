{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.swaylock;
  c = config.lib.stylix.colors;
in
{
  options.myFeatures.platforms.addons.swaylock.enable = lib.mkEnableOption "swaylock screen locker";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (name: {
      programs.swaylock = {
        enable = true;
        package = pkgs.swaylock-effects;
        settings = lib.mkForce {
          image = "${config.stylix.image}";
          scaling = "fill";

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
      };
    });
  };
}
