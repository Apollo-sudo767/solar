{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.cosmic;
in
{
  options.myFeatures.platforms.desktops.cosmic.enable =
    lib.mkEnableOption "COSMIC Desktop Environment";

  config = lib.mkIf cfg.enable {
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf config.myFeatures.core.system.preservation.enable
        {
          directories = lib.concatMap (name: [
            "/home/${name}/.config/cosmic"
            "/home/${name}/.local/share/cosmic"
          ]) config.myFeatures.core.system.users.usernames;
        };
  };
}
