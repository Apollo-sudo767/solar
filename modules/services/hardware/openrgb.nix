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
    lib.mkMerge [
      {
        # Add OpenRGB to system packages for GUI access
        environment.systemPackages = [ pkgs.openrgb-with-all-plugins ];
      }

      (lib.optionalAttrs (!isDarwin) {
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
      })
    ]
  );
}
