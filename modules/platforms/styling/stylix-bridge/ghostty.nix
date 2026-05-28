{ config, lib, ... }:

let
  cfg = config.myFeatures.programs.terminal.ghostty;
in
{
  config = lib.mkIf (cfg.enable && config.stylix.enable) {
    home-manager.sharedModules = [
      {
        stylix.targets.ghostty.enable = true;
      }
    ];
  };
}
