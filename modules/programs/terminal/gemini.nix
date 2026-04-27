{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.programs.terminal.gemini;
in
{
  options.myFeatures.programs.terminal.gemini = {
    enable = lib.mkEnableOption "Enables gemini-cli";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.gemini-cli;
      description = "The gemini-cli package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Install the package system-wide
    environment.systemPackages = [
      cfg.package
    ];

    # Example of persistent configuration via Home Manager if needed
    # This mirrors your firefox.nix logic for multi-user setups
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (name: {
      # You can add user-specific shell aliases or config files here
      home.shellAliases = {
        gemini = "gemini-cli";
      };
    });
  };
}
