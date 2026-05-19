{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.core.boot;
in
{
  config = lib.mkIf (cfg.enable && cfg.loader == "grub") {
    boot.loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
    };
  };
}
