{ config, lib, pkgs, ... }: # <-- Add pkgs.stdenv.isDarwin

let
  cfg = config.myFeatures.systems.idle;
  theme = config.myFeatures.systems.theme.gruvbox;
  lockCmd = "${pkgs.swaylock-effects}/bin/swaylock --image ${theme.wallpaper} --clock --indicator --effect-blur 7x5 --ring-color ${theme.accent} --key-hl-color ${theme.highlight}";
in {
  options.myFeatures.systems.idle.enable = lib.mkEnableOption "Swayidle/lock service";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Home Manager attributes are safe-ish
    {
      home-manager.users = lib.genAttrs config.myFeatures.core.users.usernames (name: {
        services.swayidle = {
          enable = true;
          timeouts = [
            { timeout = 300; command = lockCmd; }
            { timeout = 600; command = "niri msg action power-off-monitors"; }
          ];
          events = { 
            "before-sleep" = lockCmd; 
            "after-resume" = "niri msg action power-on-monitors"; 
          };
        };
      });
    }
    
    # Shield the Linux SystemD login service
    {
      services.logind.settings.Login.HandlelidSwitch = "suspend";
    }
  ]);
}
