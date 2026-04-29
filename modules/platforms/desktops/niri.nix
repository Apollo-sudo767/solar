{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.niri;
in
{
  options.myFeatures.platforms.desktops.niri.enable = lib.mkEnableOption "Niri Window Manager";

  # Shield everything
  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    programs.niri.package = pkgs.niri;

    environment.systemPackages =
      with pkgs;
      [
        xwayland-satellite
        networkmanagerapplet
        thunar
        awww
        brightnessctl
      ]
      ++ lib.optionals (!config.myFeatures.platforms.addons.noctalia-shell.enable) [
        fuzzel
        mako
        swaynotificationcenter
        swaybg
        swayidle
        swalock
      ];
  };
}
