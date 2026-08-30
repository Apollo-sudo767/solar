{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.gaming;
in
{
  options.myFeatures.suites.gaming = {
    enable = lib.mkEnableOption "Gaming Suite (Steam, GameScope, Controllers, Audio & Communication)";
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      programs.media = {
        gaming.enable = lib.mkDefault true;
        steam.protonInstaller.enable = lib.mkDefault true;
        mumble.enable = lib.mkDefault true;
        tf2.enable = lib.mkDefault true;
      };

      hardware.input.controllers = {
        enable = lib.mkDefault true;
        xbox = lib.mkDefault true;
        nintendo = lib.mkDefault true;
      };

      programs.utilities.social.enable = lib.mkDefault true;

      services.multimedia.audio.enable = lib.mkDefault true;
    };
  };
}
