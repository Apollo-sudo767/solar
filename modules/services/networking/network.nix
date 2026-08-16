{
  config,
  lib,
  isDarwin,
  isTotal,
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

        # Optimization: Prioritize IPv4 over IPv6 to avoid Steam CDN bottlenecks
        # and use Cloudflare DNS for faster lookups.
        networking.nameservers = [
          "1.1.1.1"
          "1.0.0.1"
        ];
        environment.etc."gai.conf".text = ''
          precedence ::ffff:0:0/96  100
        '';

        systemd.tmpfiles.rules = [
          "d /persist/etc/NetworkManager/system-connections 0700 root root - -"
        ];

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
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
      })
    ]
  );
}
