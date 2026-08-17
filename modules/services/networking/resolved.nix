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
      services.resolved.enable = true;
    }
  );
}
