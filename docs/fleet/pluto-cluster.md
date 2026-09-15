# The Pluto Cluster 🪐

The **Pluto Cluster** is a 3-node, High-Availability Kubernetes (K3s) GitOps cluster orchestrating game servers, media pipelines, home automation, and network ingress. The underlying nodes are provisioned declaratively via [Solar](https://github.com/Apollo-sudo767/solar), while workloads and infrastructure components are synchronized continuously via [Flux CD](https://fluxcd.io/) in the [`pluto-cluster`](https://github.com/Apollo-sudo767/pluto-cluster) repository.

______________________________________________________________________

## 🏛️ Cluster Architecture

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
   │   Beelink EQR5 (Ryzen)   ││  ThinkCentre M920q Tiny  ││  ThinkCentre M920q Tiny  │
   │  Bootstrap Master Node   ││   Control Plane Master   ││   Control Plane Master   │
   │    node.type=compute     ││     gpu.vendor=intel     ││     gpu.vendor=intel     │
   │   Reboot: Sun 03:00      ││    Reboot: Sun 03:30     ││    Reboot: Sun 04:00     │
   └─────────────┬────────────┘└─────────────┬────────────┘└─────────────┬────────────┘
                 └───────────────────────────┼───────────────────────────┘
                                             │
                                   Embedded etcd Quorum
                                             │
                   ┌─────────────────────────┴─────────────────────────┐
                   ▼                                                   ▼
┌───────────────────────────────────────┐   ┌─────────────────────────────────────────┐
│           Game Servers Pods           │   │     Media & Home Automation Pods        │
│ ┌───────────────────┐ ┌─────────────┐ │   │ ┌─────────────────┐ ┌─────────────────┐ │
│ │ Minecraft (Paper) │ │playit-agent │ │   │ │    Jellyfin     │ │ Home Assistant  │ │
│ │ (8GB RAM, 25565)  │ │ (Sidecar)   │ │   │ │ (Intel QuickSync│ │ (Smart Home,    │ │
│ ├───────────────────┤ └──────▲──────┘ │   │ │  Transcoding)   │ │  Port 8123)     │ │
│ │ Factorio & TF2    │        │        │   │ └────────┬────────┘ └────────┬────────┘ │
│ └─────────▲─────────┘        │        │   └──────────┼───────────────────┼──────────┘
│           └────── Loopback ──┘        │              └─────────┬─────────┘
└───────────────────▲───────────────────┘                        │
                    │ Outbound Tunnel                            ▼
                    ▼                          [ Cloudflare Tunnel (`cloudflared`) ]
           [ Playit.gg Anycast ]                                 ▲
                    ▲                                            │
          mc.yourdomain.com                              jellyfin.yourdomain.com
          (SRV Record)                                  homeassistant.yourdomain.com
```

______________________________________________________________________

## 🛰️ Physical Nodes & Constellation

The cluster maintains an embedded 3-node etcd quorum across heterogeneous hardware form factors, ensuring fault tolerance and zero downtime during maintenance:

| Node | Namesake | Hardware Specification | Role | Node Labels & Special Configs |
| :--- | :--- | :--- | :--- | :--- |
| **`hydra`** | Moon of Pluto (Hydra) | Lenovo ThinkCentre M920q Tiny (Intel Core i5-8500T, 24GB RAM, NVMe) | Bootstrap Master (`clusterInit`) | `gpu.vendor=intel`<br>Intel QuickSync GPU hardware acceleration (`/dev/dri`), Secrets sync daemon |
| **`styx`** | Moon of Pluto (Styx) | Lenovo ThinkCentre M920q Tiny (Intel Core i5-9500T, 16GB RAM, NVMe) | Control-Plane Master | `gpu.vendor=intel`<br>Intel QuickSync GPU hardware acceleration (`/dev/dri`) |
| **`pluto`** | Dwarf Planet Pluto | Beelink EQR5 (AMD Ryzen 7 5825U 8C/16T, 32GB RAM, 1TB NVMe) | Control-Plane Master | `node.type=compute`<br>High-performance CPU allocation |
| **`sol`** | Central Star (Sun) | Dedicated ZFS NAS (Multi-NIC, SAS/SATA HDD pool) | Fleet Storage Hub | Central NFS export (`/tank/k3s-volumes`) for persistent volumes |

### 🧹 Stateless Root & Impermanence

All compute nodes (`pluto`, `styx`, `hydra`) implement Solar's signature **ephemeral root on tmpfs**:

- The root filesystem (`/`) is wiped cleanly on every single reboot.
- Essential persistent state is preserved explicitly under `/persist` (K3s runtime tokens, cluster state, logs, and SSH host keys) via declarative [Preservation / Impermanence](/guide/storage-security).
- Guarantee: Nodes remain 100% immutable and reproducible from Nix expressions.

______________________________________________________________________

## 💾 Dynamic Storage Foundation

Persistent volume management is completely decoupled from individual compute nodes:

- **Dynamic Provisioner**: [`nfs-subdir-external-provisioner`](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner) deployed under `infrastructure/nfs-provisioner`.
- **Default StorageClass**: `nfs-client` with `reclaimPolicy: Retain` or `Delete` based on workload importance.
- **Two-Phase Storage Roadmap**:
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

## 📦 Workload Portfolio & Services

Workloads are declared as native Kubernetes manifests managed by Flux CD:

### 🎮 1. Dedicated Game Servers (`games` namespace)

- **Paper Minecraft 1.21.1**:
  - Pinned to `pluto` via nodeSelector `node.type: compute` for dedicated Ryzen 7 single-thread performance.
  - Allocated 8GB RAM with tuned Aikar JVM performance flags.
  - **Zero Port-Forwarding Ingress**: Includes a `playit-agent` sidecar container connecting directly to [Playit.gg](https://playit.gg/) anycast routing. External players connect via custom domain SRV records (`mc.yourdomain.com`).
- **Factorio Dedicated Server**: Headless multiplayer server mounted to persistent volume `pluto_world`.
- **Team Fortress 2 Dedicated Server**: Competitive match and casual community server.

### 🎬 2. Media Suite (`media` namespace)

- **Jellyfin Media Server**:
  - Scheduled on `hydra` using nodeSelector `gpu.vendor: intel`.
  - Passthrough of `/dev/dri` for Intel QuickSync hardware accelerated video transcoding (H.264, HEVC, AV1).
- **Servarr Automation Stack**: Sonarr, Radarr, Prowlarr integrated with qBittorrent.
- **VPN Kill-Switch**: All torrent traffic is forced through Gluetun WireGuard VPN with non-bypassable network namespace boundaries.

### 🏠 3. Home Automation (`home-automation` namespace)

- **Home Assistant Core**: Smart home orchestration with local Zigbee/Z-Wave USB device passthrough and network discovery.

______________________________________________________________________

## 🌐 Networking & Ingress Architecture

- **Internal Connectivity**: Nodes communicate over encrypted WireGuard meshes via [Tailscale](/guide/getting-started) and local gigabit LAN.
- **External Web Access**: Cloudflare Zero Trust Tunnel (`cloudflared`) connects web services (Jellyfin, Home Assistant) to public hostnames without opening ports or exposing home IP addresses.
- **External Gaming Access**: Playit.gg tunnels TCP/UDP gaming traffic through global anycast edge nodes directly to game pods.

______________________________________________________________________

## 🔄 Day-2 Operations & Maintenance

### 🛡️ High-Availability Staggered Reboots

All 3 masters run automated weekly system updates and reboots staggered by 30 minutes to preserve etcd quorum:

- **`pluto`**: Sunday 03:00 UTC (Quorum: 2/3 masters online: `styx`, `hydra`)
- **`styx`**: Sunday 03:30 UTC (Quorum: 2/3 masters online: `pluto`, `hydra`)
- **`hydra`**: Sunday 04:00 UTC (Quorum: 2/3 masters online: `pluto`, `styx`)

### 🛠️ Common Cluster Commands

```bash
# Export admin credentials
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Check cluster nodes and roles
kubectl get nodes -o wide

# Check Flux CD synchronization status
flux get kustomizations

# Force instant GitOps reconciliation
flux reconcile kustomization apps --with-source

# Tail logs of game server
kubectl logs -n games -l app=minecraft -c minecraft-server -f
```

______________________________________________________________________

## 🧭 Navigation & Next Steps

- **[Fleet Overview & Matrix](/fleet/)**: Explore the entire Solar machine constellation.
- **[Getting Started & Installation](/guide/getting-started)**: Blueprint for headless servers and clusters.
- **[Storage & Disko Architecture](/guide/storage-security)**: Ephemeral roots, NFS dynamic volumes, and ZFS storage.
- **[Universal Cheatsheet](/reference/cheatsheet)**: Cluster administration commands and aliases.
- **[Pluto Cluster Repository](https://github.com/Apollo-sudo767/pluto-cluster)**: GitOps manifests, Flux definitions, and application configs.
