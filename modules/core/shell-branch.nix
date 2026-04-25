{
  lib,
  config,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.shell;
in
{
  options.myFeatures.shell = {
    enable = lib.mkEnableOption "Interactive Shell Environment";
    p10k = lib.mkEnableOption "Powerlevel10k Theme";
    aliases = lib.mkEnableOption "Custom System Aliases";
  };

  config = lib.mkIf cfg.enable {
    myFeatures.core = {
      shell.enable = lib.mkDefault true;
      cli.enable = lib.mkDefault true;
    };
  };
}
