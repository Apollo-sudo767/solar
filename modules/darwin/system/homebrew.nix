# modules/darwin/system/homebrew.nix
# ============================================================================
# Declarative Homebrew Cask Management (`nix-darwin`)
# ============================================================================
# Manages macOS GUI applications distributed as Homebrew Casks when no native
# Nix Darwin bundle is used.
{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.darwin.system.homebrew;
in
{
  options.myFeatures.darwin.system.homebrew = {
    enable = lib.mkEnableOption "Declarative Homebrew Cask integration on macOS";
  };

  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;
      onActivation.cleanup = "none";
      casks = [
        "logseq"
        "ghostty"
      ];
    };
  };
}
