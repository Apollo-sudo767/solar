{
  config,
  lib,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.core.boot;
in
{
  config = lib.mkIf (cfg.enable && cfg.loader == "systemd") (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        boot.loader.systemd-boot = {
          enable = true;
          consoleMode = "max";
        };
      })
    ]
  );
}
