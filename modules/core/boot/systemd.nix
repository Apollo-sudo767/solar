{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.core.boot;
in
{
  config = lib.mkIf (cfg.enable && cfg.loader == "systemd") {
    boot.loader.systemd-boot = {
      enable = true;
      consoleMode = "max";
    };
  };
}
