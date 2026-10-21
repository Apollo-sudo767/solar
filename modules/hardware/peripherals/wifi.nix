# modules/hardware/peripherals/wifi.nix
# ============================================================================
# Wi-Fi Networking, Declarative SSID Profiles & State Persistence
# ============================================================================
# Enables NetworkManager with a declarative `Maximus` Wi-Fi profile (injecting
# the PSK from `age.secrets."wifi.age"` when private secrets are enabled) and
# persists `/etc/NetworkManager/system-connections` across ephemeral reboots.
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
      default = true;
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
              psk-flags = 1; # Consult secret agent / ensureProfiles secret entry for PSK
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

    # Persist saved Wi-Fi networks and regulatory/supplicant state across reboots
    # (when `services.networking` is not already preserving NetworkManager state).
    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf
        (
          config.myFeatures.core.system.preservation.enable
          && cfg.persistence
          && !(config.myFeatures.services.networking.enable or false)
        )
        {
          directories = [
            "/var/lib/NetworkManager"
            {
              directory = "/etc/NetworkManager/system-connections";
              how = "symlink";
            }
            "/etc/wpa_supplicant"
            "/var/lib/wpa_supplicant"
            "/var/lib/iwd"
          ];
        };
  };
}
