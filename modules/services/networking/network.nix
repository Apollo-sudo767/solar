{
  config,
  lib,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.services.networking;
in
{
  options.myFeatures.services.networking = {
    enable = lib.mkEnableOption "Core Networking Suite";
  };

  # Shield the Linux-only NetworkManager from macOS
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        networking.networkmanager.enable = lib.mkDefault true;

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              directories = [
                "/etc/NetworkManager/system-connections"
              ];
            };
      })
    ]
  );
}
