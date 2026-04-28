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
        environment.systemPackages = [ pkgs.bitwarden ];
      }

      # 2. Linux-only (CLI Client & Secret handling)
      (lib.optionalAttrs (!isDarwin) {
        environment.systemPackages = [ pkgs.bitwarden-cli ];
        home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
          # Home manager settings for bitwarden if any
        });
      })
    ]
  );
}
