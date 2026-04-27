{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.terminal.gemini;
in
{
  options.myFeatures.programs.terminal.gemini.enable = lib.mkEnableOption "Gemini CLI AI Agent";

  config = lib.mkIf cfg.enable {
    # Install the package globally for NixOS or MacOS (nix-darwin)
    environment.systemPackages = [ pkgs.gemini-cli ];

    # Home-manager configuration for user-specific settings
    home-manager.users = lib.genAttrs config.myFeatures.core.users.usernames (name: {
      # The tool uses ~/.gemini/settings.json for user-level configuration
      # You can manage session variables or aliases here
      home.sessionVariables = {
        GEMINI_EDITOR = "hx";
      };
    });
  };
}
