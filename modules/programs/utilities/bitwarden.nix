{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  inherit isDarwin;
  cfg = config.myFeatures.programs.utilities.bitwarden;
in
{
  options.myFeatures.programs.utilities.bitwarden = {
    enable = lib.mkEnableOption "Bitwarden Client";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # 1. Universal Bitwarden (Desktop App)
      {
        environment.systemPackages = [ pkgs.bitwarden-desktop ];
      }

      # 2. Linux-only (CLI Client & Secret handling)
      (lib.optionalAttrs (!isDarwin) {
        environment.systemPackages = [ pkgs.bitwarden-cli ];
        home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
          # Home manager settings for bitwarden if any
        });

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              directories = lib.concatMap (name: [
                "/home/${name}/.config/Bitwarden"
              ]) config.myFeatures.core.system.users.usernames;
            };
      })
    ]
  );
}
