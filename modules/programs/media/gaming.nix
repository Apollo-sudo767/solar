{
  config,
  lib,
  ...
}:

{
  options.myFeatures.programs.media.gaming = {
    enable = lib.mkEnableOption "Gaming Suite (Steam + Minecraft Java)";
  };

  config = lib.mkIf config.myFeatures.programs.media.gaming.enable {
    myFeatures.programs.media.steam.enable = lib.mkDefault true;
    myFeatures.programs.media.minecraft.java.enable = lib.mkDefault true;
  };
}
