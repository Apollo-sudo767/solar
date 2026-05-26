{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.idle;
  c = config.lib.stylix.colors;

  # Automatically uses Stylix image and colors
  lockCmd = "${pkgs.swaylock-effects}/bin/swaylock --image ${config.stylix.image} --clock --indicator --effect-blur 7x5 --ring-color ${c.base0A} --key-hl-color ${c.base08}";
in
{
  options.myFeatures.platforms.addons.idle.enable = lib.mkEnableOption "Swayidle/lock service";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      imports = [
        inputs.iron-bar.homeModules.default
      ];
      programs.ironbar.enable = true;
    });
  };
}
