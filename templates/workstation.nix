{ config, lib, ... }:

let
  cfg = config.myFeatures.workstation;
in
{
  options.myFeatures.workstation.enable = lib.mkEnableOption "General Workstation Bundle";

  config = lib.mkIf cfg.enable {
    # This single toggle enables a whole suite of apps/services
    myFeatures.programs = {
      firefox.enable = true;
      ghostty.enable = true;
      media.enable = true;
      social.enable = true;
      bitwarden.enable = true;
    };

    myFeatures.services = {
      audio.enable = true;
      printing.enable = true;
    };
  };
}
