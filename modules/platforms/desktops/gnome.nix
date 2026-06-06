{
  config,
  lib,
  pkgs,
  isTotal,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.gnome;
in
{
  options.myFeatures.platforms.desktops.gnome.enable = lib.mkEnableOption "GNOME Desktop Environment";

  # Shield everything
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        services.xserver = {
          enable = true;
          desktopManager.gnome.enable = true;
        };

        environment.gnome.excludePackages = with pkgs; [
          gnome-tour
          epiphany
        ];

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              directories = lib.concatMap (name: [
                "/home/${name}/.config/dconf"
                "/home/${name}/.local/share/gnome-shell"
                "/home/${name}/.local/share/keyrings"
              ]) config.myFeatures.core.system.users.usernames;
            };
      })
    ]
  );
}
