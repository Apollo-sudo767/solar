# modules/core/shell/shell-branch.nix
# ============================================================================
# Interactive Shell Branch (`shell-branch`)
# ============================================================================
# Convenience toggle that enables both the Zsh + Starship interactive shell
# (`shell.nix`) and the core CLI toolset (`cli.nix`).
{
  lib,
  config,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.core.shell.shell-branch;
in
{
  options.myFeatures.core.shell.shell-branch = {
    enable = lib.mkEnableOption "Interactive Shell Environment";
  };

  config = lib.mkIf (cfg.enable && isTotal) {
    myFeatures.core.shell = {
      shell.enable = lib.mkDefault true;
      cli.enable = lib.mkDefault true;
    };
  };
}
