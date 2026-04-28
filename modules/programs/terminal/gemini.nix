{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  inherit isTotal;
  cfg = config.myFeatures.programs.terminal.gemini;
in
{
  options.myFeatures.programs.terminal.gemini.enable = lib.mkEnableOption "Gemini CLI AI Agent";

  config = lib.mkIf cfg.enable {
    # 1. System-level install (NixOS/Darwin)
    environment.systemPackages = [ pkgs.gemini-cli ];

    # 2. Ensure it's in the user's path via Home Manager
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      home.packages = [ pkgs.gemini-cli ];

      # Ensure the gemini settings directory exists
      home.file.".gemini/.keep".text = "";

      # Optional: Add an alias if you prefer 'gemini' over 'gemini-cli'
      # (though the binary is usually named 'gemini')
      programs.zsh.shellAliases = {
        ai = "gemini";
      };
    });
  };
}
