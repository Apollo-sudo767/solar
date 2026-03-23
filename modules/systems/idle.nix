{ config, lib, pkgs, ... }:
let
  cfg = config.myFeatures.systems.idle;
  theme = config.myFeatures.systems.theme.gruvbox;
  
  lockCmd = "${pkgs.swaylock-effects}/bin/swaylock --image ${theme.wallpaper} --clock --indicator --effect-blur 7x5 --ring-color ${theme.accent} --key-hl-color ${theme.highlight}";
in {
  options.myFeatures.systems.idle.enable = lib.mkEnableOption "Swayidle/lock service";

  config = lib.mkIf cfg.enable {
    home-manager.users.apollo.services.swayidle = {
      enable = true;
      timeouts = [
        { timeout = 300; command = lockCmd; }
        { timeout = 600; command = "niri msg action power-off-monitors"; }
      ];
      events = [ 
        { event = "before-sleep"; command = lockCmd; }
        # Add the lock-on-lid-close event here
        { event = "after-resume"; command = "niri msg action power-on-monitors"; }
      ];
    };

    # Ensure the system actually suspends when the lid is closed
    # This tells systemd-logind to trigger the suspend state
    services.logind.lidSwitch = "suspend";
  };
}
