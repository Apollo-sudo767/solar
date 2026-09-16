{
  config,
  lib,
  inputs,
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
in
{
  config = lib.mkMerge [
    # 1. Core Secrets (User passwords, enabled via agenixPassword toggle)
    (lib.mkIf
      (
        config.myFeatures.core.system.users.agenixPassword
        && cfg.enable
        && cfg.usePrivateSecrets
        && hasPrivateSecrets
      )
      {
        age.secrets."password-apollo.age".rekeyFile = "${secretsDir}/apollo-passwd.age";
        # Allow host-specific password secrets for testing/overrides
        age.secrets."password-${config.networking.hostName}.age".rekeyFile =
          "${secretsDir}/apollo-passwd.age";
      }
    )

    # 2. Optional Secrets (Only if agenix feature is enabled)
    (lib.mkIf (cfg.enable && cfg.usePrivateSecrets && hasPrivateSecrets) {
      age.secrets."wifi.age".rekeyFile = "${secretsDir}/maximus-wifi.age";
    })

    # 3. K3s Cluster & Workload Secrets (Nix-managed)
    (lib.mkIf
      (
        cfg.enable
        && cfg.usePrivateSecrets
        && hasPrivateSecrets
        && (builtins.pathExists "${secretsDir}/k3s-token.age")
      )
      {
        age.secrets."k3s-token.age".rekeyFile = "${secretsDir}/k3s-token.age";
      }
    )
    (lib.mkIf
      (
        cfg.enable
        && cfg.usePrivateSecrets
        && hasPrivateSecrets
        && (builtins.pathExists "${secretsDir}/playit-secret.age")
      )
      {
        age.secrets."playit-secret.age".rekeyFile = "${secretsDir}/playit-secret.age";
      }
    )
    (lib.mkIf
      (
        cfg.enable
        && cfg.usePrivateSecrets
        && hasPrivateSecrets
        && (builtins.pathExists "${secretsDir}/cloudflared-credentials.age")
      )
      {
        age.secrets."cloudflared-credentials.age".rekeyFile = "${secretsDir}/cloudflared-credentials.age";
      }
    )
    (lib.mkIf
      (
        cfg.enable
        && cfg.usePrivateSecrets
        && hasPrivateSecrets
        && (builtins.pathExists "${secretsDir}/surfshark-vpn.age")
      )
      {
        age.secrets."surfshark-vpn.age".rekeyFile = "${secretsDir}/surfshark-vpn.age";
      }
    )
    (lib.mkIf
      (
        cfg.enable
        && cfg.usePrivateSecrets
        && hasPrivateSecrets
        && (builtins.pathExists "${secretsDir}/github-token.age")
      )
      {
        age.secrets."github-token.age" = {
          rekeyFile = "${secretsDir}/github-token.age";
          mode = "0444";
        };
        nix.extraOptions = ''
          !include ${config.age.secrets."github-token.age".path}
        '';
      }
    )
  ];
}
