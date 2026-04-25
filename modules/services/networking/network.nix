{ config, lib, isDarwin, ... }: # Added isDarwin

let
  cfg = config.myFeatures.services.networking;
in
{
  options.myFeatures.services.networking = {
    enable = lib.mkEnableOption "Core Networking Suite";
  };

  # Shield the Linux-only NetworkManager from macOS
  config = lib.mkIf cfg.enable (lib.optionalAttrs (!isDarwin) {
    networking.networkmanager.enable = lib.mkDefault true;
  });
}
