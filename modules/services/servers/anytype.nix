{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myFeatures.services.servers.anytype;
  # Use the bundle from inputs for the specific logic
  anySyncPackage = inputs.any-sync-bundle.packages.${pkgs.system}.default;
in
{
  options.myFeatures.services.servers.anytype = {
    enable = lib.mkEnableOption "Anytype Sync Server";
    port = lib.mkOption {
      type = lib.types.port;
      default = 33010;
      description = "TCP port for the Anytype sync node (DRPC).";
    };
    quicPort = lib.mkOption {
      type = lib.types.port;
      default = 33020;
      description = "UDP port for the Anytype sync node (QUIC).";
    };
    website = {
      enable = lib.mkEnableOption "Nginx virtual host for Anytype";
      domain = lib.mkOption {
        type = lib.types.str;
        default = "anytype.local";
        description = "Domain name for the Anytype website.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # MongoDB 7.0 is pulled from nixpkgs-unstable binaries
    services.mongodb = {
      enable = true;
      package = pkgs.mongodb-7_0;
    };

    # Redis is pulled from standard nixpkgs binaries
    services.redis.servers."any-sync" = {
      enable = true;
      port = 6379;
    };

    systemd.services.any-sync = {
      description = "Anytype Sync Server Bundle";
      after = [
        "network.target"
        "mongodb.service"
        "redis.service"
      ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${anySyncPackage}/bin/any-sync-bundle --config /var/lib/any-sync/config.yml";
        Restart = "always";
        User = "any-sync";
        Group = "any-sync";
        StateDirectory = "any-sync";
        WorkingDirectory = "/var/lib/any-sync";
        # Security hardening
        NoNewPrivileges = true;
        ProtectSystem = "full";
      };

      preStart = ''
        if [ ! -f /var/lib/any-sync/config.yml ]; then
          ${anySyncPackage}/bin/any-sync-bundle --config /var/lib/any-sync/config.yml || true
        fi
      '';
    };

    users.users.any-sync = {
      isSystemUser = true;
      group = "any-sync";
      home = "/var/lib/any-sync";
    };

    users.groups.any-sync = { };

    services.nginx.virtualHosts."${cfg.website.domain}" = lib.mkIf cfg.website.enable {
      enableACME = lib.mkDefault false;
      forceSSL = lib.mkDefault false;
      locations."/" = {
        root = pkgs.writeTextDir "index.html" ''
          <html>
            <head><title>Anytype Sync Server</title></head>
            <body>
              <h1>Anytype Sync Server</h1>
              <p>The sync server is running on this host.</p>
              <ul>
                <li>DRPC Port: ${toString cfg.port}</li>
                <li>QUIC Port: ${toString cfg.quicPort}</li>
              </ul>
            </body>
          </html>
        '';
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.quicPort ];
    };
  };
}
