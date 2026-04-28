{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.kde;
in
{
  options.myFeatures.platforms.desktops.kde.enable = lib.mkEnableOption "KDE Plasma 6 Desktop";

  # Shield everything
  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.desktopManager.plasma6.enable = true;
    programs.kde-pim.enable = false;

    environment.systemPackages = with pkgs; [
      kdePackages.krunner
      kdePackages.plasma-nm
      kdePackages.plasma-pa
      kdePackages.dolphin
      kdePackages.spectacle
      kdePackages.ark
      kdePackages.qtstyleplugin-kvantum
    ];

    xdg.portal.extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };
}
