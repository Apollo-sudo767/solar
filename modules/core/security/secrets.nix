# modules/core/security/secrets.nix
# ============================================================================
# Declarative Agenix Secret Routing (`age.secrets`)
# ============================================================================
# Maps encrypted `.age` files from the private `solar-secrets` input to
# `/run/agenix/<secret>` on each host.
#
# Feature-Gated Secret Provisioning:
# Each secret is strictly gated on whether the target host actually enables the
# corresponding feature or service. This prevents hosts from decrypting (or
# requiring rekeyed `.age` files for) secrets they never use.
{
  config,
  lib,
  inputs,
  isDarwin ? false,
  isTotal,
  useSecrets ? true,
  ...
}:

let
  cfg = config.myFeatures.core.security.agenix;
  hasPrivateSecrets =
    (builtins.hasAttr "solar-secrets" inputs)
    && (inputs.solar-secrets ? outPath)
    && (builtins.pathExists "${inputs.solar-secrets}/secrets")
    && useSecrets;
  secretsDir = if hasPrivateSecrets then inputs.solar-secrets + "/secrets" else "";
  secretsEnabled = cfg.enable && cfg.usePrivateSecrets && hasPrivateSecrets && isTotal;

  # Feature flags used to gate individual secrets per host
  wifiEnabled = !isDarwin && (config.myFeatures.hardware.peripherals.wifi.enable or false);
  k3sEnabled = !isDarwin && (config.services.k3s.enable or false);
  k3sSecretSyncEnabled = !isDarwin && (config.myFeatures.services.k3s.secretSync.enable or false);
  cloudflareEnabled = !isDarwin && (config.myFeatures.services.networking.cloudflare.enable or false);
  surfsharkEnabled = config.myFeatures.services.networking.surfshark.enable or false;
  ddnsEnabled = !isDarwin && (config.myFeatures.services.networking.ddns.enable or false);
in
{
  config = lib.mkMerge [
    # 1. User Account Password Hash (`password-apollo.age`)
    # Uses `cluster-passwd.age` on K3s cluster nodes (hydra, pluto, styx) and
    # `apollo-passwd.age` on workstations/NAS hosts.
    (lib.mkIf (secretsEnabled && config.myFeatures.core.system.users.agenixPassword) {
      age.secrets."password-apollo.age".rekeyFile =
        if
          (lib.elem config.networking.hostName [
            "hydra"
            "pluto"
            "styx"
          ])
          && (builtins.pathExists "${secretsDir}/cluster-passwd.age")
        then
          "${secretsDir}/cluster-passwd.age"
        else
          "${secretsDir}/apollo-passwd.age";
    })

    # 2. Wi-Fi Pre-Shared Key (`wifi.age` -> NetworkManager `Maximus` profile)
    # Only provisioned on hosts with `myFeatures.hardware.peripherals.wifi.enable = true`.
    (lib.mkIf (secretsEnabled && wifiEnabled) {
      age.secrets."wifi.age".rekeyFile = "${secretsDir}/maximus-wifi.age";
    })

    # 3. K3s Cluster Join Token (`k3s-token.age`)
    # Only provisioned on K3s nodes or hosts running K3s secret sync.
    (lib.mkIf
      (
        secretsEnabled
        && (k3sEnabled || k3sSecretSyncEnabled)
        && (builtins.pathExists "${secretsDir}/k3s-token.age")
      )
      {
        age.secrets."k3s-token.age".rekeyFile = "${secretsDir}/k3s-token.age";
      }
    )

    # 4. K3s Workload Secrets (`playit-secret.age` & `tf2-secret.age`)
    # Synced into Kubernetes namespaces by `modules/services/servers/k3s-secrets-sync.nix`.
    (lib.mkIf
      (secretsEnabled && k3sSecretSyncEnabled && (builtins.pathExists "${secretsDir}/playit-secret.age"))
      {
        age.secrets."playit-secret.age".rekeyFile = "${secretsDir}/playit-secret.age";
      }
    )
    (lib.mkIf
      (secretsEnabled && k3sSecretSyncEnabled && (builtins.pathExists "${secretsDir}/tf2-secret.age"))
      {
        age.secrets."tf2-secret.age".rekeyFile = "${secretsDir}/tf2-secret.age";
      }
    )
    (lib.mkIf
      (secretsEnabled && k3sSecretSyncEnabled && (builtins.pathExists "${secretsDir}/matrix-secret.age"))
      {
        age.secrets."matrix-secret.age".rekeyFile = "${secretsDir}/matrix-secret.age";
      }
    )

    # 5. Cloudflare Tunnel Credentials (`cloudflared-credentials.age`)
    # Provisioned when either K3s secretSync or the host-level cloudflared service is enabled.
    (lib.mkIf
      (
        secretsEnabled
        && (k3sSecretSyncEnabled || cloudflareEnabled)
        && (builtins.pathExists "${secretsDir}/cloudflared-credentials.age")
      )
      {
        age.secrets."cloudflared-credentials.age".rekeyFile = "${secretsDir}/cloudflared-credentials.age";
      }
    )

    # 6. Surfshark WireGuard/OpenVPN Credentials (`surfshark-vpn.age`)
    # Provisioned when either host-level Surfshark or K3s media-namespace secretSync is enabled.
    (lib.mkIf
      (
        secretsEnabled
        && (surfsharkEnabled || k3sSecretSyncEnabled)
        && (builtins.pathExists "${secretsDir}/surfshark-vpn.age")
      )
      {
        age.secrets."surfshark-vpn.age".rekeyFile = "${secretsDir}/surfshark-vpn.age";
      }
    )

    # 7. Cloudflare Dynamic DNS API Token (`cloudflare-ddns-token.age`)
    # Provisioned when either host-level DDNS or K3s infrastructure secretSync is enabled.
    (lib.mkIf
      (
        secretsEnabled
        && (ddnsEnabled || k3sSecretSyncEnabled)
        && (builtins.pathExists "${secretsDir}/cloudflare-ddns-token.age")
      )
      {
        age.secrets."cloudflare-ddns-token.age".rekeyFile = "${secretsDir}/cloudflare-ddns-token.age";
      }
    )

    # 8. GitHub Personal Access Token (`github-token.age`)
    # Prevents GitHub API rate-limiting during Nix flake evaluations and configures Git credentials.
    (lib.mkIf
      (secretsEnabled && cfg.enableGithubToken && (builtins.pathExists "${secretsDir}/github-token.age"))
      (
        {
          age.secrets."github-token.age" = {
            rekeyFile = "${secretsDir}/github-token.age";
            mode = "0444";
          };
          nix.extraOptions = ''
            !include ${config.age.secrets."github-token.age".path}
          '';
        }
        // lib.optionalAttrs (!isDarwin) {
          programs.git = {
            enable = true;
            config = {
              credential."https://github.com".helper =
                "!f() { echo username=Apollo-sudo767; echo password=$(cut -d= -f3 /run/agenix/github-token.age 2>/dev/null); }; f";
            };
          };
        }
      )
    )
  ];
}
