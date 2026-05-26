{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.swayosd;
  inherit (config.myFeatures.core.system.users) usernames;
in
{
  options.myFeatures.platforms.addons.swayosd.enable = lib.mkEnableOption "SwayOSD";

  config = lib.mkIf cfg.enable {
    # SwayOSD requires a system service for libinput/backlight access
    services.swayosd.enable = true;

    home-manager.users = lib.genAttrs usernames (_name: {
      # Home Manager doesn't have a swayosd module yet, so we just add the package 
      # and the client-side service if needed, but the NixOS service handles the daemon.
      home.packages = [ pkgs.swayosd ];
    });
  };
}
