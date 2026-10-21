# modules/programs/utilities/appstore/gnome-software.nix
#
# Configures GNOME Software (GTK4/Libadwaita Flatpak software center),
# dconf support, and state preservation on NixOS.
{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.appstore.gnome-software;
in
{
  options.myFeatures.programs.utilities.appstore.gnome-software = {
    enable = lib.mkEnableOption "GNOME Software (GTK4/Libadwaita Flatpak store)";
  };

  config = lib.mkIf cfg.enable {
    # Ensure Flatpak subsystem is active so GNOME Software can manage apps
    myFeatures.services.system.flatpak.enable = lib.mkDefault true;

    services.gnome.gnome-software.enable = true;
    programs.dconf.enable = lib.mkDefault true;

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".local/share/gnome-software"
              ".cache/gnome-software"
            ];
          });
        };
  };
}
