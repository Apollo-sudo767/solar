# Fleet Overview 🪐

Solar manages a constellation of specialized machines, each named after planets and moons in the solar system.

______________________________________________________________________

## 🌑 The Pluto K3s High-Availability Cluster

The **Pluto Cluster** is a 3-node, High-Availability Kubernetes (K3s) control plane powered by an embedded etcd quorum. All three nodes run ephemeral wipe-on-boot roots with Disko, stateless compute (`--disable=local-storage`), and delegate dynamic persistent storage to Sol's ZFS pool over NFS. Weekly system upgrades and reboots occur on Sundays, staggered by 30 minutes.

> [!TIP]
> For the dedicated cluster architecture, network topology, storage integration, and operational runbooks, see **[The Pluto Cluster](Pluto-Cluster.md)**.

| Host | Celestial Body | Role & Architecture | Key Highlights |
| :--- | :--- | :--- | :--- |
| **`pluto`** | Dwarf Planet Pluto | **K3s HA Bootstrap Master**<br>• Beelink EQR5 (Ryzen 7 5825U, 32GB RAM) | Headless server, Limine, Ephemeral tmpfs root + Preservation, Agenix, K3s embedded etcd bootstrap master (`clusterInit`), `node.type=compute`, Wake-on-LAN, watchdog, weekly upgrade Sun 03:00, Tailscale mesh. |
| **`styx`** | Moon of Pluto (Styx) | **K3s HA Master Node 2**<br>• ThinkPad T14 Gen 2 (16GB RAM) | Headless server, Limine, Ephemeral tmpfs root + Preservation, Agenix, K3s embedded etcd master, 40–50% battery cap, lid switch ignore, NIC power saving disabled, Wake-on-LAN, watchdog, weekly upgrade Sun 03:30, Tailscale mesh. |
| **`hydra`** | Moon of Pluto (Hydra) | **K3s HA Master Node 3**<br>• ThinkCentre M920q (i5-8500T, 16GB RAM) | Headless server, Limine, Ephemeral tmpfs root + Preservation, Agenix, K3s embedded etcd master, `gpu.vendor=intel`, Intel QuickSync `/dev/dri`, Wake-on-LAN, watchdog, weekly upgrade Sun 04:00, Tailscale mesh. |

______________________________________________________________________

## 🌐 Server & Storage Infrastructure

| Host | Celestial Body | Role & Hardware | Hosted Services & Configuration |
| :--- | :--- | :--- | :--- |
| **`sol`** | The Sun (Central Star) | **Central Fleet ZFS NAS**<br>• Storage Server (NVMe + HDDs) | ZFS mirrored pool (`tank`, LZ4, POSIX ACLs), NFS export (`/tank/k3s-volumes`) for K3s dynamic PVs, Samba SMB3, Avahi mDNS (`sol.local`), Agenix secrets, wipe-on-boot preservation, SMART diagnostics, weekly ZFS scrub & auto-snapshots. |
| **`venus`** | Planet Venus | **Multi-Service Server**<br>• AMD CPU | Nginx reverse proxy with automated Dynamic DNS & Lego SSL certificates, Joplin Server, Zotero sync server, LanguageTool grammar server, dedicated Factorio & Minecraft servers. |
| **`thebe`** | Inner Moon (Jupiter XIV) | **Compact Standalone Server**<br>• Intel Mac Mini (Core CPU & iGPU) | UEFI `limine` bootloader, Disko LUKS + Btrfs on SATA/NVMe SSD, `applesmc` thermal monitoring, AppArmor, Tailscale mesh VPN, key-only SSH. Self-contained with zero private secret dependencies. |

______________________________________________________________________

## 🚀 Workstations, Laptops & Portable Devices

| Host | Celestial Body | Role & Architecture | Key Highlights |
| :--- | :--- | :--- | :--- |
| **`mars`** | Planet Mars | **Primary Workstation**<br>• AMD CPU + Nvidia GPU | Niri scrollable Wayland compositor, ReGreet, wipe-on-boot tmpfs root, multi-NVMe speed pool + HDD bulk pool, Sunshine game streaming, Wooting keyboard support. |
| **`mercury`** | Planet Mercury | **Portable Laptop**<br>• Intel CPU/iGPU | Niri Wayland compositor, aggressive power/battery saving profiles, trackpad gestures, wipe-on-boot tmpfs root. |
| **`elara`** | Moon of Jupiter | **Gaming & Media Rig**<br>• AMD CPU + Nvidia GPU | KDE Plasma, SDDM, Stylix Strawberry theme, Steam Gamescope, Sunshine streaming server, DaVinci Resolve, OBS Studio. |
| **`europa`** | Moon of Jupiter | **VR & Media Rig**<br>• Intel CPU + Nvidia GPU | KDE Plasma, Meta Quest wired VR support, video recording/editing suite. |
| **`amalthea`** | Moon of Jupiter | **Handheld Console**<br>• Intel Atom z8350 | Auto-boots directly into Steam Big Picture via Gamescope on KDE Plasma, low-power Atom kernel optimizations. |
| **`phobos`** | Moon of Mars | **MacBook**<br>• Apple Silicon (`aarch64-darwin`) | Managed via `nix-darwin`, Homebrew bundle integration, system defaults, Logseq, Raycast, AP-Office. |
| **`io`** | Moon of Jupiter | **Testbed Node**<br>• x86_64 Linux | Rust-based COSMIC Desktop Environment & COSMIC Greeter, Stylix Space theme. |

______________________________________________________________________

## ⚠️ Deprecated Legacy Hosts

> [!NOTE]
> The legacy Jupiter Moon storage nodes have been retired in favor of **`sol`** (Central ZFS NAS) and the **Pluto Cluster**:
>
> - **`ganymede`** (Dedicated NAS): **Deprecated** — superseded by **`sol`**.
> - **`callisto`** (Storage & Backup): **Deprecated** — superseded by **`sol`** and the **Pluto Cluster**.
> - **`thebe`** remains actively maintained as a standalone compact server node.

______________________________________________________________________

## 🧭 Navigation & Next Steps

- 🪐 **[The Pluto Cluster Documentation](Pluto-Cluster.md)**
- 💾 **[Storage & Disko Guide](Storage-&-Disko.md)**
- 🖧 **[Setting Up a Basic Server](Setting-Up-a-Basic-Server.md)**
- ⚡ **[Quick Reference & Cheatsheet](Quick-Reference-&-Cheatsheet.md)**
- 🏠 **[Return to Wiki Home](Home.md)**
