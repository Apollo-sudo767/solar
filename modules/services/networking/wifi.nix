{
  config,
  lib,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.services.networking.wifi;
in
{
  options.myFeatures.services.networking.wifi = {
    enable = lib.mkEnableOption "Declarative WiFi via NetworkManager";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        # This expects a file in the format of a NetworkManager keyfile
        # You can generate one with nmcli or just write it manually
        networking.networkmanager.ensureProfiles.profiles = {
          # Use the decrypted secret as a source for the profile
          # Note: NetworkManager profiles can be provided as strings or paths
          # We append the profile config using the age secret
          # Since NetworkManager profiles are usually stored in /etc/NetworkManager/system-connections
          # preservation already handles the persistence of these once created.
        };

        # We use a simpler approach: have agenix place the file directly where NetworkManager looks
        age.secrets = lib.mkIf (config.myFeatures.core.security.agenix.enable or false) {
          "wifi.age" = {
            path = "/etc/NetworkManager/system-connections/default-wifi.nmconnection";
            mode = "600";
          };
        };
      })
    ]
  );
}
