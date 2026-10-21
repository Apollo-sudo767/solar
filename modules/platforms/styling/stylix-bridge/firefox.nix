# modules/platforms/styling/stylix-bridge/firefox.nix
#
# Bridges Stylix Firefox profile theming across configured system users.
{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.programs.browsers.firefox;
in
{
  config = lib.mkIf ((cfg.enable || cfg.nightly.enable) && config.stylix.enable) {
    home-manager.sharedModules = [
      {
        stylix.targets.firefox.profileNames = config.myFeatures.core.system.users.usernames;
      }
    ];
  };
}
