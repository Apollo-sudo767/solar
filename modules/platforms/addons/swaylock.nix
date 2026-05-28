{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.swaylock;
in
{
  options.myFeatures.platforms.addons.swaylock.enable = lib.mkEnableOption "swaylock screen locker";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      programs.swaylock = {
        enable = true;
        package = pkgs.swaylock-effects;
        settings =
          let
            c =
              if config.stylix.enable then
                config.lib.stylix.colors
              else
                {
                  base00 = "282828";
                  base01 = "3c3836";
                  base05 = "ebdbb2";
                  base0D = "83a598";
                  base08 = "fb4934";
                  base0B = "b8bb26";
                  base0A = "fabd2f";
                };
          in
          lib.mkForce (
            {
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
            }
            // lib.optionalAttrs config.stylix.enable {
              image = "${config.stylix.image}";
            }
          );
      };
    });
  };
}
