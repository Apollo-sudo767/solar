{
  config,
  lib,
  isDarwin,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.services.networking.resolved;
in
{
  options.myFeatures.services.networking.resolved = {
    enable = lib.mkEnableOption "systemd-resolved network name resolution manager";
  };

  config = lib.mkIf cfg.enable (
    lib.optionalAttrs (!isDarwin) {
      services.resolved = {
        enable = true;
        settings.Resolve = {
          DNSSEC = "false";
          DNS = [
            "1.0.0.1"
            "9.9.9.9"
          ];
          FallbackDNS = [
            "1.1.1.1"
            "8.8.8.8"
          ];
        };
      };

      networking.networkmanager.dns = lib.mkIf config.networking.networkmanager.enable (
        lib.mkDefault "systemd-resolved"
      );
    }
  );
}
