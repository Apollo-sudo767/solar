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
        # Disabled because config changes or fallback boot paths cause Blake2b hash mismatch
        boot.loader.limine.enrollConfig = false;

        # 3. Add management tools
        environment.systemPackages = [ pkgs.sbctl ];

        # 4. Persistence
        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              directories = [
                {
                  directory = "/var/lib/sbctl";
                  mode = "0700";
                }
              ];
            };
      })
    ]
  );
}
