{ config, lib, ... }:

let
  cfg = config.myFeatures.services.networking;
in
{
  options.myFeatures.services.networking = {
    enable = lib.mkEnableOption "Core Networking Suite";
  };

  # Shield the Linux-only NetworkManager from macOS
  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = lib.mkDefault true;

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && !pkgs.stdenv.isDarwin)
        {
          directories = [
            "/etc/NetworkManager/system-connections"
          ];
        };
  };
}
