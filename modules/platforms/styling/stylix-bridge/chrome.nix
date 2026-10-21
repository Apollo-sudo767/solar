# modules/platforms/styling/stylix-bridge/chrome.nix
#
# Bridges Stylix Chromium theming when Chrome/Chromium is enabled.
{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.programs.browsers.chrome;
in
{
  config = lib.mkIf (cfg.enable && config.stylix.enable) {
    stylix.targets.chromium.enable = true;
  };
}
