# The Fleet 🪐

Solar orchestrates an entire constellation of 15 specialized machines across desktop workstations, portable laptops, handheld gaming devices, central storage servers, and a High-Availability Kubernetes cluster.

______________________________________________________________________

## 🗺️ The Constellation Map

| Host | Celestial Namesake | Role & Architecture | Platform & UI | Storage Configuration |
| :--- | :--- | :--- | :--- | :--- |
| **`sol`** | The Sun (Central Star) | **Central Fleet ZFS NAS**<br>• Storage Server (NVMe + HDDs) | Headless Server | Ephemeral `tmpfs` + 1x NVMe + 2x HDD (ZFS Mirror `tank`) |
| **`mars`** | Planet Mars | **Primary Workstation**<br>• AMD CPU + Nvidia GPU | Niri (Sky Theme) | Ephemeral `tmpfs` + 2x NVMe + 2x HDD |
| **`mercury`** | Planet Mercury | **Portable Laptop**<br>• Intel CPU/iGPU | Niri (Sky Theme) | Ephemeral `tmpfs` + 1x NVMe |
| **`phobos`** | Moon of Mars | **MacBook**<br>• Apple Silicon (`aarch64-darwin`) | macOS + nix-darwin | APFS Encrypted |
| **`pluto`** | Dwarf Planet Pluto | **K3s HA Bootstrap Master**<br>• Beelink EQR5 (Ryzen 7 5825U, 32GB RAM) | Headless / K3s HA | Ephemeral `tmpfs` + 1x NVMe (Stateless K3s) |
| **`styx`** | Moon of Pluto (Styx) | **K3s HA Master Node 2**<br>• ThinkCentre M920q (i5-9500T, 16GB RAM) | Headless / K3s HA | Ephemeral `tmpfs` + 1x NVMe (Stateless K3s) |
| **`hydra`** | Moon of Pluto (Hydra) | **K3s HA Master Node 3**<br>• ThinkCentre M720q (i5-8500T, 24GB RAM) | Headless / K3s HA | Ephemeral `tmpfs` + 1x NVMe (Stateless K3s) |
| **`thebe`** | Inner Moon (Jupiter XIV) | **Compact Standalone Server**<br>• Intel Mac Mini (Core CPU & iGPU) | Headless / Limine | Standard Btrfs + LUKS2 |
| **`venus`** | Planet Venus | **Multi-Service Server**<br>• AMD CPU | Headless Server | Standard Btrfs + 1x NVMe |
| **`elara`** | Moon of Jupiter | **Gaming Rig**<br>• AMD CPU + Nvidia GPU | KDE Plasma 6 (Strawberry) | Standard Btrfs + 1x SSD |
| **`europa`** | Moon of Jupiter | **VR Workstation**<br>• Intel CPU + Nvidia GPU | KDE Plasma 6 (Forest) | Standard Btrfs + 1x SSD |
| **`amalthea`** | Moon of Jupiter | **Handheld Console**<br>• Intel Atom z8350 | Steam Big Picture (Gamescope) | Standard Btrfs + eMMC/SD |
| **`io`** | Moon of Jupiter | **Testbed Node**<br>• x86_64 Linux | COSMIC Desktop (Space) | Standard Btrfs |

::: info Deprecated Legacy Hosts
Legacy storage hosts **`ganymede`** (Dedicated NAS) and **`callisto`** (Storage & Backup) have been retired in favor of **`sol`** (Central ZFS NAS) and the **Pluto Cluster**. **`thebe`** remains actively maintained as a standalone compact server.
:::

______________________________________________________________________

## 🌑 The Pluto K3s HA Cluster

The **Pluto Cluster** is a 3-node High-Availability Kubernetes control plane powered by an embedded etcd quorum.

- **Nodes**: **`pluto`** (Bootstrap Master), **`styx`** (Master 2), and **`hydra`** (Master 3).
- **Stateless Compute**: Local hostpath storage is disabled (`--disable=local-storage`). Persistent volumes are dynamically provisioned over NFS from **`sol`** (`nfs-client`).
- **Staggered Reboots**: System updates and automatic reboots occur Sundays 30 minutes apart to preserve etcd quorum:
  - `pluto`: Sun 03:00
  - `styx`: Sun 03:30
  - `hydra`: Sun 04:00

::: tip Dedicated Guide
For complete deployment manifests, bootstrap commands, and storage integration, see the dedicated [Pluto Cluster Guide](./pluto-cluster.md).
:::

______________________________________________________________________

## ☀️ Sol (Central Fleet ZFS NAS)

- **Storage Layout**: Mirrored 3.5" HDD storage pool (**`tank`**) with LZ4 compression, POSIX ACLs, and automated snapshots.
- **NFS Export**: Exports `/tank/k3s-volumes` to cluster subnet for dynamic persistent volumes.
- **Samba SMB3**: Encrypted network file shares (`/tank/storage`, `/tank/media`) with Avahi mDNS discovery (`sol.local`).
- **Maintenance**: Automated weekly ZFS scrubs and SMART diagnostics.

______________________________________________________________________

## ☁️ Venus (Multi-Service Cloud)

- **Web Proxy**: Automated Nginx reverse proxy with dynamic DNS and Lego Let's Encrypt SSL.
- **Productivity**: Joplin note synchronization, Zotero research backend, and LanguageTool grammar server.
- **Game Hosting**: Dedicated Factorio server and NeoForge Minecraft servers.

______________________________________________________________________

## 🛰️ Thebe (Intel Mac Mini Server)

- **Hardware**: Repurposed Intel Mac Mini running headless NixOS with `applesmc` thermal control.
- **Security**: Disko LUKS2 encryption, AppArmor profiles, and Tailscale mesh networking.
- **Zero-Secret Bootstrap**: Operates completely self-contained with no private secret dependencies.

______________________________________________________________________

## 🚀 Workstations & Mobility

### Mars (Primary Desktop)

- AMD CPU + Nvidia GPU powering the scrollable Niri Wayland compositor.
- Wipe-on-boot tmpfs root, multi-NVMe speed pool + HDD storage pool.
- Sunshine game streaming host and Wooting analog keyboard support.

### Mercury (Portable Laptop)

- Intel CPU with aggressive power saving profiles via TLP.
- Niri Wayland compositor with gesture-driven workspace navigation.
- Ephemeral root on fast NVMe.

### Phobos (Apple Silicon MacBook)

- Managed via `nix-darwin` with declarative system preferences.
- Raycast, Homebrew bundles, and unified shell tools with Linux hosts.
