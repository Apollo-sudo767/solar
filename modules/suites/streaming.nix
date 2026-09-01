{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.streaming;
in
{
  options.myFeatures.suites.streaming = {
    enable = lib.mkEnableOption "Game & Display Streaming Host Suite (Sunshine)";
    port = lib.mkOption {
      type = lib.types.int;
      default = 48000;
      description = "Sunshine server port";
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures.services.multimedia.sunshine = {
      enable = true;
      inherit (cfg) port;
    };
  };
}
