{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.programs.office.languagetool;
in
{
  options.myFeatures.programs.office.languagetool = {
    enable = lib.mkEnableOption "LanguageTool Desktop proofreading & style linter application";
    apiUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://localhost:8010";
      description = "Self-hosted LanguageTool API backend URL for local text analysis & linting.";
    };
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
