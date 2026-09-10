# The Pluto Cluster 🪐

The **Pluto Cluster** is a 3-node High-Availability Kubernetes (K3s) GitOps cluster orchestrating game servers, media streaming, smart home automation, and encrypted ingress. Underlying nodes are provisioned declaratively via [Solar](https://github.com/Apollo-sudo767/solar), while workloads and infrastructure manifests are continuously reconciled via [Flux CD](https://fluxcd.io/) in [`pluto-cluster`](https://github.com/Apollo-sudo767/pluto-cluster).

______________________________________________________________________

## 🏛️ Cluster Topology & Architecture

```
                      ┌─────────────────────────────────────────┐
                      │       Sol (Central ZFS Storage NAS)     │
                      │       NFS: sol.local:/tank/k3s-volumes  │
                      └────────────────────┬────────────────────┘
                                           │ Dynamic NFS Storage (nfs-client)
                 ┌─────────────────────────┼─────────────────────────┐
                 │                         │                         │
                 ▼                         ▼                         ▼
   ┌──────────────────────────┐┌──────────────────────────┐┌──────────────────────────┐
   │         pluto            ││           styx           ││          hydra           │
   │   Beelink EQR5 (Ryzen)   ││   ThinkPad T14 Gen 2     ││  ThinkCentre M920q Tiny  │
   │  Bootstrap Master Node   ││   Control Plane Master   ││   Control Plane Master   │
   │    node.type=compute     ││      Battery capped      ││     gpu.vendor=intel     │
   │   Reboot: Sun 03:00      ││    Reboot: Sun 03:30     ││    Reboot: Sun 04:00     │
   └─────────────┬────────────┘└─────────────┬────────────┘└─────────────┬────────────┘
                 └───────────────────────────┼───────────────────────────┘
                                             │
                                   Embedded etcd Quorum
```

______________________________________________________________________

## 🛰️ Physical Nodes Specification

| Node | Namesake | Hardware Spec | Role | Special System Configurations |
| :--- | :--- | :--- | :--- | :--- |
| **`pluto`** | Dwarf Planet Pluto | Beelink EQR5 (AMD Ryzen 7 5825U 8C/16T, 32GB RAM, NVMe) | Bootstrap Master (`clusterInit`) | `node.type=compute`<br>Secrets sync daemon, high-performance CPU allocation |
| **`styx`** | Moon of Pluto (Styx) | Lenovo ThinkPad T14 Gen 2 (Intel Core i5, 16GB RAM, NVMe) | Control-Plane Master | Built-in battery UPS, battery capped at 50% (`TLP`), lid-switch ignored |
| **`hydra`** | Moon of Pluto (Hydra) | Lenovo ThinkCentre M920q Tiny (Intel Core i5-8500T, 16GB RAM, NVMe) | Control-Plane Master | `gpu.vendor=intel`<br>Intel QuickSync GPU hardware acceleration (`/dev/dri`) |
| **`sol`** | Central Star (Sun) | Dedicated ZFS NAS (Multi-NIC, SAS/SATA HDD pool) | Fleet Storage Hub | Central NFS export (`/tank/k3s-volumes`) for persistent volumes |

### 🧹 Stateless Root & Impermanence

All compute nodes (`pluto`, `styx`, `hydra`) implement Solar's signature **ephemeral root on tmpfs**:

- The root filesystem (`/`) is wiped cleanly on every single reboot.
- Essential persistent state is preserved explicitly under `/persist` (K3s runtime tokens, cluster state, logs, and SSH host keys).
- Guarantee: Nodes remain 100% immutable and reproducible from Nix expressions.

______________________________________________________________________

## 💾 Dynamic Storage Foundation

Persistent volume management is completely decoupled from individual compute nodes:

- **Dynamic Provisioner**: [`nfs-subdir-external-provisioner`](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner) deployed under `infrastructure/nfs-provisioner`.
- **Default StorageClass**: `nfs-client` with `reclaimPolicy: Retain` or `Delete`.
- **Storage Roadmap**:
  1. **Phase 1 (Bootstrap / Standalone)**: `pluto` exports `/persist/k3s-volumes` via local NFS for zero-dependency operation before the central NAS is provisioned.
  1. **Phase 2 (Fleet Production)**: Volumes migrate smoothly to `sol.local:/tank/k3s-volumes` on the central ZFS array, providing hardware redundancy, automated snapshots, and offsite replication.

______________________________________________________________________

## 🔒 Secrets Management (Agenix & Zero-Plaintext GitOps)

The Pluto cluster enforces a strict **Zero Plaintext Secrets** policy in Git:

> [!IMPORTANT]
> No secret manifests, environment files, or credentials exist in the [`pluto-cluster`](https://github.com/Apollo-sudo767/pluto-cluster) repository.

1. **Source of Truth**: All secrets are stored as encrypted Age files (`*.age`) inside [`solar-secrets`](https://github.com/Apollo-sudo767/solar-secrets) and decrypted natively by NixOS using host SSH keys and YubiKeys.
1. **K3s Secrets Sync Service**:
   On `pluto`, NixOS runs `k3s-secrets-sync.service`. When K3s becomes ready on boot, this systemd unit securely creates or updates Kubernetes Secret resources directly via `kubectl`:
   - `k3s-token.age` -> Cluster join token for HA quorum initialization.
   - `playit-secret.age` -> Secret in namespace `games` for Playit.gg tunnel authentication.
   - `cloudflared-credentials.age` -> Secret in namespace `cloudflared` for Cloudflare Tunnel ingress.
   - `surfshark-vpn.age` -> Secret in namespace `media` for Gluetun WireGuard VPN.

______________________________________________________________________

## 📦 Workload Portfolio

- **🎮 Paper Minecraft 1.21.1**: Pinned to `pluto` (`node.type=compute`), 8GB RAM, Aikar JVM flags, with [Playit.gg](https://playit.gg/) anycast sidecar for zero-port-forwarding multiplayer.
- **🏭 Factorio Dedicated Server**: Headless multiplayer server mounted to persistent volume `pluto_world`.
- **🔫 Team Fortress 2 Dedicated Server**: Competitive match and casual community server.
- **🎬 Jellyfin Media Server**: Pinned to `hydra` (`gpu.vendor: intel`) with `/dev/dri` hardware QuickSync transcoding.
- **🤖 Servarr Stack & VPN**: Sonarr, Radarr, Prowlarr, and qBittorrent forced through Gluetun WireGuard VPN.
- **🏠 Home Assistant**: Smart home automation with local device passthrough.

______________________________________________________________________

## 🔄 Staggered Quorum Maintenance

All 3 masters run automated weekly system updates and reboots staggered by 30 minutes on Sunday to preserve etcd quorum:

- **`pluto`**: Sunday 03:00 UTC (Quorum: 2/3 masters online: `styx`, `hydra`)
- **`styx`**: Sunday 03:30 UTC (Quorum: 2/3 masters online: `pluto`, `hydra`)
- **`hydra`**: Sunday 04:00 UTC (Quorum: 2/3 masters online: `pluto`, `styx`)

______________________________________________________________________

## 🔗 Related Wiki Pages

- **[Fleet Overview](Fleet-Overview.md)**: Explore the entire Solar machine constellation.
- **[Storage & Disko](Storage-&-Disko.md)**: Declarative partitioning and filesystem layout.
- **[Security & Hardening](Security-&-Hardening.md)**: Cryptographic secrets workflow.
- **[Pluto Cluster GitOps Repository](https://github.com/Apollo-sudo767/pluto-cluster)**: Workload manifests and configs.
