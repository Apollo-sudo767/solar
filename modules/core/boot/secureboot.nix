{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.core.boot;
in
{
  config = lib.mkIf (cfg.enable && cfg.secureBoot.enable) (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        # 1. Enable native Limine signing during rebuilds
        boot.loader.limine.secureBoot.enable = true;

        # 2. Recommended: Embed a hash of your config in the binary
        # This prevents tampering with kernel params (like init=/bin/sh)
        boot.loader.limine.enrollConfig = true;

        # 3. Add management tools
        environment.systemPackages = [ pkgs.sbctl ];
      })
    ]
  );
}
