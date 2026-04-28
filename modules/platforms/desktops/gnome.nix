{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.gnome;
in
{
  options.myFeatures.platforms.desktops.gnome.enable = lib.mkEnableOption "GNOME Desktop Environment";

  # Shield everything
  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
    };

    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      epiphany
    ];
  };
}
