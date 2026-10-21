# modules/core/system/fonts.nix
# ============================================================================
# Core System Fonts Configuration
# ============================================================================
# Installs baseline developer Nerd Fonts (JetBrains Mono & Fira Code) across
# both Linux and macOS hosts, and enables default system font packages on Linux.
# Enabled automatically by `myFeatures.core.system.core-branch`.
{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.core.system.fonts;
in
{
  options.myFeatures.core.system.fonts = {
    enable = lib.mkEnableOption "Core System Fonts";
  };

  config = lib.mkIf (cfg.enable && isTotal) (
    lib.mkMerge [
      # 1. Universal Fonts (Installed on both macOS and Linux)
      {
        fonts.packages = with pkgs; [
          nerd-fonts.jetbrains-mono
          nerd-fonts.fira-code
        ];
      }

      # 2. Linux-Only Default Font Packages
      (lib.optionalAttrs (!isDarwin) {
        fonts.enableDefaultPackages = true;
      })
    ]
  );
}
