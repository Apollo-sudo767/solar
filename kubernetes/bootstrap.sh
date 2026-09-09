#!/usr/bin/env bash
# kubernetes/bootstrap.sh
# Bootstraps Flux CD and initial secrets onto the Pluto K3s HA cluster.
set -euo pipefail

REPO_OWNER="Apollo-sudo767"
REPO_NAME="solar"
CLUSTER_PATH="./kubernetes/clusters/pluto"
BRANCH="main"

echo "🪐 Pluto K3s Cluster GitOps Bootstrap"
echo "======================================"

# 1. Check prerequisites
for cmd in kubectl flux; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "❌ Error: '$cmd' is not installed or not in PATH."
    exit 1
  fi
done

# 2. Check cluster connection
echo "📡 Checking K3s cluster connection..."
kubectl cluster-info || {
  echo "❌ Error: Cannot connect to K3s cluster. Check KUBECONFIG."
  exit 1
}

# 3. Bootstrap Flux CD
echo "🚀 Bootstrapping Flux CD from GitHub repository ($REPO_OWNER/$REPO_NAME)..."
flux bootstrap github \
  --owner="$REPO_OWNER" \
  --repository="$REPO_NAME" \
  --branch="$BRANCH" \
  --path="$CLUSTER_PATH" \
  --personal

echo "✅ Flux CD successfully bootstrapped!"
echo "Reconciling infrastructure and application workloads..."
flux reconcile kustomization flux-system --with-source
