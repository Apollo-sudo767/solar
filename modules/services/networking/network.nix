{ config, lib, ... }:

let
  cfg = config.myFeatures.services.networking;
in
{
  options.myFeatures.services.networking = {
    enable = lib.mkEnableOption "Core Networking Suite";
  };

  # This base file can also hold general networking tweaks (DNS, etc.) 
  # if you decide to add them later.
  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = lib.mkDefault true;
  };
}
