{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.hardware.peripherals.wifi;
in
{
  options.myFeatures.hardware.peripherals.wifi = {
    enable = lib.mkEnableOption "Enables Wifi Services";
    persistence = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to persist WiFi network connections across reboots.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager = {
      enable = true;
      ensureProfiles = {
        profiles = {
          Maximus = {
            connection = {
              id = "Maximus";
              type = "wifi";
              autoconnect = true;
            };
            wifi = {
              mode = "infrastructure";
              ssid = "Maximus";
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk-flags = 1; # Consult secret agent for psk
            };
          };
        };
        secrets.entries = lib.optionals (config.age.secrets ? "wifi.age") [
          {
            matchId = "Maximus";
            matchSetting = "802-11-wireless-security";
            key = "psk";
            file = config.age.secrets."wifi.age".path;
          }
        ];
      };
    };

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && cfg.persistence)
        {
          directories = [
            "/var/lib/NetworkManager"
            {
              directory = "/etc/NetworkManager/system-connections";
              how = "symlink";
            }
          ];
        };
  };
}
