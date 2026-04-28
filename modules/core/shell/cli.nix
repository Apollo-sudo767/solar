{
  pkgs,
  lib,
  config,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.core.shell.cli;
in
{
  options.myFeatures.core.shell.cli = {
    enable = lib.mkEnableOption "Core CLI Utilities";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bat
      eza
      fzf
      ripgrep
      fd
      htop
      jq
      tree
    ];
  };
}
