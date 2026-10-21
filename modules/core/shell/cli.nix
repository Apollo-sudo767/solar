# modules/core/shell/cli.nix
# ============================================================================
# Core Command-Line Utilities (`myFeatures.core.shell.cli`)
# ============================================================================
# Installs essential modern CLI replacements and system inspection tools
# (`bat`, `eza`, `fzf`, `ripgrep`, `fd`, `btop`, `jq`, `helix`, `comma`, etc.)
# across both NixOS and macOS hosts.
{
  pkgs,
  lib,
  config,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.core.shell.cli;
in
{
  options.myFeatures.core.shell.cli = {
    enable = lib.mkEnableOption "Core CLI Utilities";
  };

  config = lib.mkIf (cfg.enable && isTotal) {
    environment.systemPackages = with pkgs; [
      bat
      eza
      fzf
      ripgrep
      fd
      htop
      jq
      tree
      git
      helix
      comma
      btop
      curl
      wget
      cachix
    ];
  };
}
