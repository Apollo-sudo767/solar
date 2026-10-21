# modules/platforms/desktops/cosmic.nix
# ============================================================================
# System76 COSMIC Epoch Wayland Desktop Environment
# ============================================================================
# Enables the COSMIC desktop session and preserves user COSMIC configuration
# across reboots. Login greeter selection (`cosmic-greeter` vs `regreet`/etc.)
# is managed via `myFeatures.platforms.addons.displayManager.manager`.
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
