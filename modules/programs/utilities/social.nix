{
  config,
  lib,
  ...
}:

{
  options.myFeatures.programs.utilities.social = {
    enable = lib.mkEnableOption "Social Suite (Spotify + Vesktop)";
  };

  config = lib.mkIf config.myFeatures.programs.utilities.social.enable {
    myFeatures.programs.utilities.spotify.enable = lib.mkDefault true;
    myFeatures.programs.utilities.vesktop.enable = lib.mkDefault true;
  };
}
