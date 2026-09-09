# Server & Cloud Infrastructure 🌐

______________________________________________________________________

## ☀️ Sol (Central Fleet ZFS NAS & Storage Hub)

**Sol** (*The Sun*) is the central storage and file-sharing backbone of the Solar constellation, configured with ZFS, wipe-on-boot preservation, and private secrets management via Agenix.

- **Hardware**: Dedicated Storage Server (Intel Core CPU, multi-NIC Gigabit/10GbE, SAS/SATA HBA)
- **Storage Layout**: Declarative Disko partitioning:
  - **OS Boot Drive**: Fast NVMe (`/dev/nvme0n1`) with 1GB ESP (`/boot`) and ephemeral tmpfs root with Btrfs `/persist` and `/nix`.
  - **ZFS Storage Pool**: Mirrored 3.5" HDD storage pool (**`tank`**) with LZ4 compression, POSIX ACLs (`acltype=posixacl`), and extended attributes (`xattr=sa`).
- **Bootloader**: Limine UEFI
- **Maintenance**: Automated ZFS scrubs (`services.zfs.autoScrub`), automated snapshot retention (`services.zfs.snapshot` / `autoSnapshot`), and SMART drive diagnostics (`smartd`).
- **NFS Storage Export**: Exports `/tank/k3s-volumes` to the fleet subnet with options `rw,async,no_subtree_check,no_root_squash` (ports 111 & 2049 open in firewall) to serve dynamic persistent volumes for the K3s cluster.
- **Samba SMB3**: Shares `/tank/storage` and `/tank/media` with SMB3 enforcement and Avahi mDNS discovery (`sol.local`).

______________________________________________________________________

## ☁️ Venus (Multi-Service Home Cloud)

**Venus** is a multi-service Linux server providing web hosting, encrypted synchronization, and multiplayer gaming.

### 🌐 Web & Proxy Services

- **Nginx Reverse Proxy**: Automatic SSL termination using Lego ACME client.
- **Dynamic DNS (DDNS)**: Automated multi-domain dynamic DNS updater for:
  - `joplin.apollan.cc`
  - `zotero.apollan.cc`
  - `languagetool.apollan.cc`
  - `factorio.apollan.cc`
  - `nomansland.apollan.cc`

### 📚 Self-Hosted Productivity

- **Joplin Server**: Encrypted cloud note synchronization.
- **Zotero Server**: Academic research and bibliography synchronization backend.
- **LanguageTool Server**: Self-hosted grammar and spelling correction API.

### 🎮 Dedicated Game Servers

- **Factorio**: Dedicated game server listening on UDP port 34197.
- **Minecraft No Man's Land**: PhasMC 1.21.1 NeoForge modpack server listening on port 19132 (Simple Voice Chat on UDP 24454).
- **Minecraft SLLV**: Dedicated survival server listening on port 25565.

______________________________________________________________________

## 🌑 The Pluto K3s High-Availability Cluster

The **Pluto Cluster** is a 3-node, High-Availability Kubernetes (K3s) control plane powered by an embedded etcd quorum. All three nodes operate as control-plane masters, ephemeral wipe-on-boot preservation hosts, and Agenix-managed secret consumers. To enforce stateless compute nodes, local hostpath storage is disabled (`--disable=local-storage`), delegating all persistent storage dynamically to Sol's ZFS NFS pool (`nfs-client`).

To protect the etcd quorum from simultaneous failure during maintenance, all nodes run automated weekly system upgrades and reboots on Sunday, staggered precisely 30 minutes apart.

### 🪐 Pluto (Bootstrap Master — Slot 1: Sun 03:00)

- **Celestial Namesake**: Dwarf Planet Pluto (134340 Pluto)
- **Hardware**: Beelink EQR5 (AMD Ryzen 7 5825U, 32GB RAM)
- **Role**: K3s HA Cluster Bootstrap Master (`clusterInit = true`)
- **Node Labels**: `node.type=compute`
- **Storage**: Ephemeral tmpfs root with Disko Btrfs on NVMe (`/dev/nvme0n1`) and stateless K3s (`--disable=local-storage`)
- **Reliability & Power**: Wake-on-LAN enabled, kernel hardware watchdog timer (`services.watchdog.enable = true`)
- **Maintenance Schedule**: Weekly automated upgrade and reboot every Sunday at **03:00** (`rebootWindow`: 03:00–03:20)
- **Networking & Firewall**: Key-only SSH (port 22), K3s supervisor API (port 6443), etcd HA quorum (ports 2379, 2380), Kubelet metrics (port 10250), Flannel VXLAN overlay (UDP 8472), Tailscale mesh.

### 🌊 Styx (Master Node 2 — Slot 2: Sun 03:30)

- **Celestial Namesake**: Styx (Pluto II, inner moon of Pluto)
- **Hardware**: Lenovo ThinkPad T14 Gen 2 (Intel Core CPU, 16GB RAM)
- **Role**: K3s HA Control-Plane Master (`serverAddr = "https://pluto:6443"`)
- **Laptop Server Optimizations**:
  - **Battery Conservation**: Hard charge threshold capped at 40–50% via TLP and sysfs to eliminate battery degradation under continuous AC power.
  - **Lid-Close Handling**: Suspend disabled (`HandleLidSwitch = "ignore"`).
  - **Network Performance**: Network card power saving disabled via TLP and NetworkManager.
- **Reliability & Power**: Wake-on-LAN enabled, kernel hardware watchdog timer (`services.watchdog.enable = true`)
- **Maintenance Schedule**: Weekly automated upgrade and reboot every Sunday at **03:30** (`rebootWindow`: 03:30–03:50)
- **Networking & Firewall**: Ports identical to Pluto (22, 6443, 2379, 2380, 10250, UDP 8472).

### 🐉 Hydra (Master Node 3 — Slot 3: Sun 04:00)

- **Celestial Namesake**: Hydra (Pluto III, outer moon of Pluto)
- **Hardware**: Lenovo ThinkCentre M920q Tiny (Intel Core i5-8500T, 16GB RAM)
- **Role**: K3s HA Control-Plane Master (`serverAddr = "https://pluto:6443"`)
- **Node Labels**: `gpu.vendor=intel`
- **GPU & Hardware Video Transcoding**:
  - Intel GPU drivers (`hardware.graphics.enable = true`, `intel-media-driver`)
  - Intel QuickSync `/dev/dri` access permissions configured for container offloading.
- **Reliability & Power**: Wake-on-LAN enabled, kernel hardware watchdog timer (`services.watchdog.enable = true`)
- **Maintenance Schedule**: Weekly automated upgrade and reboot every Sunday at **04:00** (`rebootWindow`: 04:00–04:20)
- **Networking & Firewall**: Ports identical to Pluto and Styx (22, 6443, 2379, 2380, 10250, UDP 8472).

______________________________________________________________________

## 📦 Cluster GitOps & Core Workloads (Flux CD)

The cluster workloads and dynamic storage are declaratively synchronized via **Flux CD** from the dedicated [`pluto-cluster`](https://github.com/Apollo-sudo767/pluto-cluster) repository:

1. **Dynamic Storage (`nfs-client`)**: `nfs-subdir-external-provisioner` provisions persistent volumes dynamically from Sol's ZFS mirror pool (`sol.local:/tank/k3s-volumes`).
1. **Minecraft Server**: Running `itzg/minecraft-server` with 8GB RAM allocated, pinned to Beelink EQR5 (`node.type=compute`), with a `playit-agent` sidecar for portless external friend access.
1. **Jellyfin Media Server**: Pinned to the M920q (`gpu.vendor: intel`) with `/dev/dri` hardware-accelerated QuickSync video transcoding.
1. **Cloudflared Tunnel**: Secure, zero-port-forwarding HTTPS ingress to cluster web services (e.g. `jellyfin.yourdomain.com`).
1. **Home Assistant**: Smart home automation running with dedicated persistent volume storage.
