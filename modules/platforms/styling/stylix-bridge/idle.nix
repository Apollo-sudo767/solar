{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.idle;
  c = config.lib.stylix.colors;
in
{
  config = lib.mkIf (cfg.enable && config.stylix.enable) {
    home-manager.sharedModules = [
      {
        services.swayidle =
          let
            lockCmd = "${pkgs.swaylock-effects}/bin/swaylock --image ${config.stylix.image} --clock --indicator --effect-blur 7x5 --ring-color ${c.base0A} --key-hl-color ${c.base08}";
          in
          {
            timeouts = [
              {
                timeout = 300;
                command = lockCmd;
              }
            ];
            events = {
              "before-sleep" = lockCmd;
            };
          };
      }
    ];
  };
}
