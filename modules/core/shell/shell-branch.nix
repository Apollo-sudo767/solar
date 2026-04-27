{
  lib,
  config,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.core.shell.shell-branch;
in
{
  options.myFeatures.core.shell.shell-branch = {
    enable = lib.mkEnableOption "Interactive Shell Environment";
    p10k = lib.mkEnableOption "Powerlevel10k Theme";
    aliases = lib.mkEnableOption "Custom System Aliases";
  };

  config = lib.mkIf cfg.enable {
    myFeatures.core.shell = {
      shell.enable = lib.mkDefault true;
      cli.enable = lib.mkDefault true;
    };
  };
}
