{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.programs.terminal.antigravity;
in
{
  options.myFeatures.programs.terminal.antigravity.enable =
    lib.mkEnableOption "Antigravity CLI Agent";

  config = lib.mkIf cfg.enable {
    # 1. Install system-wide cleanly
    environment.systemPackages = [ pkgs.antigravity-cli ];

    # 2. Set the alias system-wide so it works regardless of HM state
    environment.shellAliases = {
      float = "antigravity";
    };

    # 3. Persistence configuration for stateful data
    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && !pkgs.stdenv.isDarwin)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              # No need for .keep files now, preservation will safely provision the directory structure
              ".config/antigravity"
              ".gemini"
            ];
          });
        };
  };
}
