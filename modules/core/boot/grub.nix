{
  config,
  lib,
  isTotal,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.core.boot;
in
{
  config = lib.mkIf (cfg.enable && cfg.loader == "grub") (
    lib.optionalAttrs (!isDarwin) {
      boot.loader.grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
      };
    }
  );
}
