# modules/services/hardware/printing.nix
#
# Configures CUPS printing support, Avahi mDNS discovery, and state
# preservation on Linux while keeping options cross-platform safe on macOS.
{
  config,
  lib,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.services.hardware.printing;
in
{
  options.myFeatures.services.hardware.printing.enable = lib.mkEnableOption "CUPS Printing Support";

  config = lib.mkIf cfg.enable (
    lib.optionalAttrs (!isDarwin) {
      services.printing.enable = true;
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
        lib.mkIf config.myFeatures.core.system.preservation.enable
          {
            directories = [
              "/var/lib/cups"
              "/var/spool/cups"
              "/var/cache/cups"
            ];
          };
    }
  );
}
