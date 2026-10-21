# modules/programs/office/languagetool.nix
# ============================================================================
# LanguageTool Desktop Proofreading & Style Linter
# ============================================================================
# Installs the standalone LanguageTool grammar/style checker and preserves user
# dictionary/configuration files under `~/.config/LanguageTool` on Linux.
{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.programs.office.languagetool;
in
{
  options.myFeatures.programs.office.languagetool = {
    enable = lib.mkEnableOption "LanguageTool Desktop proofreading & style linter application";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.languagetool ];

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && !isDarwin)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [ ".config/LanguageTool" ];
          });
        };
  };
}
