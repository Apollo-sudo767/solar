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
        # Disabled to prevent Blake2b / SHA hash mismatch panics (hash_mismatch_panic) on rebuilds
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
