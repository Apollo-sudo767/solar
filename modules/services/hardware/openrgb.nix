# modules/services/hardware/openrgb.nix
# ============================================================================
# OpenRGB Hardware Lighting Daemon & GUI
# ============================================================================
# Enables the NixOS `services.hardware.openrgb` daemon with all plugins (which
# also installs the OpenRGB package into `environment.systemPackages` and
# configures udev rules), loads `i2c-dev` for motherboard/RAM SMBus access,
# and preserves user lighting profiles.
{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.services.hardware.openrgb;
in
{
  options.myFeatures.services.hardware.openrgb.enable = lib.mkEnableOption "OpenRGB";

  config = lib.mkIf cfg.enable (
    lib.optionalAttrs (!isDarwin) {
      services.hardware.openrgb = {
        enable = true;
        package = pkgs.openrgb-with-all-plugins;
      };

      # Ensure i2c-dev is loaded for motherboard/RAM control
      boot.kernelModules = [ "i2c-dev" ];

      preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
        lib.mkIf config.myFeatures.core.system.preservation.enable
          {
            directories = lib.concatMap (name: [
              "/home/${name}/.config/OpenRGB"
            ]) config.myFeatures.core.system.users.usernames;
          };
    }
  );
}
