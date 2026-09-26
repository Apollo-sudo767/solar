{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.services.k3s.secretSync;
in
{
  options.myFeatures.services.k3s.secretSync = {
    enable = lib.mkEnableOption "Nix-managed Kubernetes secret synchronization into K3s";
    playitSecretPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = config.age.secrets."playit-secret.age".path or null;
      description = "Path to decrypted Playit secret file.";
    };
    cloudflaredCredentialsPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = config.age.secrets."cloudflared-credentials.age".path or null;
      description = "Path to decrypted Cloudflared credentials file.";
    };
    surfsharkVpnSecretPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = config.age.secrets."surfshark-vpn.age".path or null;
      description = "Path to decrypted Surfshark VPN WireGuard credentials file.";
    };
    cloudflareDdnsTokenPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = config.age.secrets."cloudflare-ddns-token.age".path or null;
      description = "Path to decrypted Cloudflare DDNS API token file.";
    };
  };

  config = lib.mkIf (config.services.k3s.enable && cfg.enable) {
    systemd.services.k3s-secret-sync = {
      description = "Synchronize Nix-managed secrets into Kubernetes namespaces";
      after = [ "k3s.service" ];
      wants = [ "k3s.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "10s";
      };
      path = [
        config.services.k3s.package
        pkgs.kubectl
        pkgs.coreutils
      ];
      script = ''
        KUBECONFIG="/etc/rancher/k3s/k3s.yaml"

        # Wait for Kubernetes API server to become responsive
        until kubectl --kubeconfig "$KUBECONFIG" get nodes &>/dev/null; do
          echo "Waiting for K3s API server readiness..."
          sleep 3
        done

        echo "K3s API is ready. Synchronizing Nix-managed secrets into Kubernetes..."

        # 1. Minecraft Playit Secret (Namespace: games)
        PLAYIT_PATH="${
          if cfg.playitSecretPath != null then
            toString cfg.playitSecretPath
          else
            "/persist/etc/kubernetes/secrets/playit-secret"
        }"
        if [ -f "$PLAYIT_PATH" ]; then
          kubectl --kubeconfig "$KUBECONFIG" create namespace games --dry-run=client -o yaml | kubectl --kubeconfig "$KUBECONFIG" apply -f -
          PLAYIT_KEY=$(cat "$PLAYIT_PATH" | tr -d '\n\r ')
          kubectl --kubeconfig "$KUBECONFIG" create secret generic playit-secret \
            --namespace=games \
            --from-literal=PLAYIT_SECRET_KEY="$PLAYIT_KEY" \
            --dry-run=client -o yaml | kubectl --kubeconfig "$KUBECONFIG" apply -f -
          echo "Synchronized playit-secret in namespace 'games'."
        fi

        # 2. Cloudflare Tunnel Credentials (Namespace: cloudflared)
        CF_PATH="${
          if cfg.cloudflaredCredentialsPath != null then
            toString cfg.cloudflaredCredentialsPath
          else
            "/persist/etc/kubernetes/secrets/cloudflared-credentials.json"
        }"
        if [ -f "$CF_PATH" ]; then
          kubectl --kubeconfig "$KUBECONFIG" create namespace cloudflared --dry-run=client -o yaml | kubectl --kubeconfig "$KUBECONFIG" apply -f -
          kubectl --kubeconfig "$KUBECONFIG" create secret generic cloudflared-credentials \
            --namespace=cloudflared \
            --from-file=credentials.json="$CF_PATH" \
            --dry-run=client -o yaml | kubectl --kubeconfig "$KUBECONFIG" apply -f -
          echo "Synchronized cloudflared-credentials in namespace 'cloudflared'."
        fi

        # 3. Surfshark WireGuard VPN Credentials (Namespace: media)
        SURFSHARK_PATH="${
          if cfg.surfsharkVpnSecretPath != null then
            toString cfg.surfsharkVpnSecretPath
          else
            "/persist/etc/kubernetes/secrets/surfshark-vpn.env"
        }"
        if [ -f "$SURFSHARK_PATH" ]; then
          kubectl --kubeconfig "$KUBECONFIG" create namespace media --dry-run=client -o yaml | kubectl --kubeconfig "$KUBECONFIG" apply -f -
          kubectl --kubeconfig "$KUBECONFIG" create secret generic surfshark-vpn-secret \
            --namespace=media \
            --from-env-file="$SURFSHARK_PATH" \
            --dry-run=client -o yaml | kubectl --kubeconfig "$KUBECONFIG" apply -f -
          echo "Synchronized surfshark-vpn-secret in namespace 'media'."
        fi

        # 4. Cloudflare DDNS API Token (Namespace: infrastructure)
        CF_DDNS_PATH="${
          if cfg.cloudflareDdnsTokenPath != null then
            toString cfg.cloudflareDdnsTokenPath
          else
            "/persist/etc/kubernetes/secrets/cloudflare-ddns-token"
        }"
        if [ -f "$CF_DDNS_PATH" ]; then
          kubectl --kubeconfig "$KUBECONFIG" create namespace infrastructure --dry-run=client -o yaml | kubectl --kubeconfig "$KUBECONFIG" apply -f -
          CF_TOKEN=$(cat "$CF_DDNS_PATH" | tr -d '\n\r ')
          kubectl --kubeconfig "$KUBECONFIG" create secret generic cloudflare-ddns-secret \
            --namespace=infrastructure \
            --from-literal=CLOUDFLARE_API_TOKEN="$CF_TOKEN" \
            --from-literal=CF_API_TOKEN="$CF_TOKEN" \
            --dry-run=client -o yaml | kubectl --kubeconfig "$KUBECONFIG" apply -f -
          echo "Synchronized cloudflare-ddns-secret in namespace 'infrastructure'."
        fi

        echo "Nix-managed secret synchronization complete."
      '';
    };
  };
}
