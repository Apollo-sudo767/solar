{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  inherit isTotal;
  cfg = config.myFeatures.programs.terminal.antigravity;
in
{
  options.myFeatures.programs.terminal.antigravity.enable =
    lib.mkEnableOption "Antigravity CLI Agent";

  config = lib.mkIf cfg.enable {
    # 1. System-level install (NixOS/Darwin)
    environment.systemPackages = [ pkgs.antigravity-cli ];

    # 2. Ensure it's in the user's path via Home Manager
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      home.packages = [ pkgs.antigravity-cli ];

      # Ensure the antigravity settings directory exists
      home.file.".config/antigravity/.keep".text = "";

      # Shell alias for the new CLI
      programs.zsh.shellAliases = {
        float = "antigravity";
      };
    });

    # 3. Persistence configuration for stateful data
    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && !pkgs.stdenv.isDarwin)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [ ".config/antigravity" ];
          });
        };
  };
}
