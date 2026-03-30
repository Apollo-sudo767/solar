{ config, lib, pkgs, ... }:
let
  cfg = config.myFeatures.systems.idle;
  theme = config.myFeatures.systems.theme.gruvbox;
  
  lockCmd = "${pkgs.swaylock-effects}/bin/swaylock --image ${theme.wallpaper} --clock --indicator --effect-blur 7x5 --ring-color ${theme.accent} --key-hl-color ${theme.highlight}";
in {
  options.myFeatures.systems.idle.enable = lib.mkEnableOption "Swayidle/lock service";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.myFeatures.core.users.usernames (name: {
      services.swayidle = {
        enable = true;
        timeouts = [
          { timeout = 300; command = lockCmd; }
          { timeout = 600; command = "niri msg action power-off-monitors"; }
        ];
        events = [ 
          { event = "before-sleep"; command = lockCmd; }
          { event = "after-resume"; command = "niri msg action power-on-monitors"; }
        ];
      };
    });

    services.logind.settings.Login.HandlelidSwitch = "suspend";
  };
}
