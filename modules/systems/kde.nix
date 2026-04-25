{
  config,
  lib,
  pkgs,
  ...
}: # <-- Add pkgs.stdenv.isDarwin

let
  cfg = config.myFeatures.systems.kde;
in
{
  options.myFeatures.systems.kde.enable = lib.mkEnableOption "KDE Plasma 6 Desktop";

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
