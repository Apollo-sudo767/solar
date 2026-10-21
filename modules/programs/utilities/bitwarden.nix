# modules/programs/utilities/bitwarden.nix
# ============================================================================
# Bitwarden Password Manager (Desktop & CLI)
# ============================================================================
# Installs the Bitwarden desktop client across platforms and adds the `bw` CLI
# client plus `~/.config/Bitwarden` state preservation on Linux.
{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

let
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

      # 2. Linux-only (CLI Client & Ephemeral Root Preservation)
      (lib.optionalAttrs (!isDarwin) {
        environment.systemPackages = [ pkgs.bitwarden-cli ];

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
                directories = [
                  ".config/Bitwarden"
                  ".config/Bitwarden CLI"
                ];
              });
            };
      })
    ]
  );
}
