{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.kde;
in
{
  options.myFeatures.platforms.desktops.kde.enable = lib.mkEnableOption "KDE Plasma 6 Desktop";

  # Shield everything
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
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

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              directories = lib.concatMap (name: [
                "/home/${name}/.config/kde.org"
                "/home/${name}/.local/share/kwalletd"
                "/home/${name}/.local/share/konsole"
                "/home/${name}/.local/share/dolphin"
              ]) config.myFeatures.core.system.users.usernames;
              files = lib.concatMap (name: [
                "/home/${name}/.config/plasma-org.kde.plasma.desktop-appletsrc"
              ]) config.myFeatures.core.system.users.usernames;
            };
      })
    ]
  );
}
