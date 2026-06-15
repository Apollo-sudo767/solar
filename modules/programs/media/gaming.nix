{
  config,
  lib,
  ...
}:

{
  options.myFeatures.programs.media.gaming = {
    enable = lib.mkEnableOption "Gaming Suite (Steam + Prism Launcher)";
  };

  config = lib.mkIf config.myFeatures.programs.media.gaming.enable {
    myFeatures.programs.media.steam.enable = lib.mkDefault true;
    myFeatures.programs.media.prism.enable = lib.mkDefault true;
  };
}
