# Server & Cloud Infrastructure 🌐

______________________________________________________________________

## ☀️ Sol (Central Fleet NAS & Storage Hub)

**Sol** (*The Sun*) is the central storage and file-sharing backbone of the Solar constellation, configured with wipe-on-boot preservation, full LUKS encryption, and private secrets management via Agenix.

- **Hardware**: Dedicated Storage Server (Intel Core CPU, multi-NIC Gigabit/10GbE, SAS/SATA HBA)
- **Storage**: Universal Disko Btrfs with NVMe OS cache (`/dev/nvme0n1`) + Multi-HDD encrypted bulk pool (`/persist/bulk`)
- **Bootloader**: Limine UEFI
- **Role**: Central Fleet NAS (Samba SMB3, NFSv4, Avahi mDNS, SMART diagnostics, weekly Btrfs scrub)
- **Preservation & Secrets**: Ephemeral tmpfs root with state preserved at `/persist` and `/persist/bulk`, automated Agenix password and key management.

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

The **Pluto Cluster** is a 3-node, High-Availability Kubernetes (K3s) control plane powered by an embedded etcd quorum. All three nodes operate as control-plane masters, ephemeral wipe-on-boot preservation hosts, and Agenix-managed secret consumers.

To protect the etcd quorum from simultaneous failure during maintenance, all nodes run automated weekly system upgrades and reboots on Sunday, staggered precisely 30 minutes apart.

### 🪐 Pluto (Bootstrap Master — Slot 1: Sun 03:00)

- **Celestial Namesake**: Dwarf Planet Pluto (134340 Pluto)
- **Hardware**: Lenovo ThinkCentre M920q Tiny (Intel Core CPU, vPro / Intel UHD 630 Graphics)
- **Memory**: 32 GB DDR4 SODIMM
- **Storage**: Ephemeral tmpfs root with Disko Btrfs on NVMe (`/dev/nvme0n1`)
- **Bootloader**: Limine UEFI
- **Role**: K3s High-Availability Cluster Bootstrap Master (`clusterInit = true`)
- **Preservation & Secrets**: Preserves `/persist`, `/var/lib/rancher`, `/etc/rancher`; Agenix secrets enabled.
- **Maintenance Schedule**: Weekly automated upgrade and reboot every Sunday at **03:00** (`rebootWindow`: 03:00–03:20).
- **Networking & Firewall**: Key-only SSH (port 22), K3s supervisor API (port 6443), etcd HA quorum (ports 2379, 2380), Kubelet metrics (port 10250), Flannel VXLAN overlay (UDP 8472), Tailscale mesh.

### 🌓 Charon (Master Node 2 — Slot 2: Sun 03:30)

- **Celestial Namesake**: Charon (Pluto I, largest moon of Pluto)
- **Hardware**: Repurposed Intel 16GB Node (Intel Core CPU, Thunderbolt, NVMe)
- **Memory**: 16 GB DDR4 SODIMM
- **Storage**: Ephemeral tmpfs root with Disko Btrfs on NVMe (`/dev/nvme0n1`)
- **Bootloader**: Limine UEFI
- **Role**: K3s High-Availability Control-Plane Master (`serverAddr = "https://pluto:6443"`)
- **Hardware Hardening**:
  - **Battery Conservation**: Hard charge threshold cap at 50% via systemd and dynamic udev rules to prevent battery degradation under 24/7 power.
  - **Lid Switch**: Configured with `HandleLidSwitch = "ignore"` for uninterrupted headless server operation.
- **Preservation & Secrets**: Preserves `/persist`, `/var/lib/rancher`, `/etc/rancher`; Agenix secrets enabled.
- **Maintenance Schedule**: Weekly automated upgrade and reboot every Sunday at **03:30** (`rebootWindow`: 03:30–03:50).
- **Networking & Firewall**: Ports identical to Pluto (22, 6443, 2379, 2380, 10250, UDP 8472).

### 🐉 Hydra (Master Node 3 — Slot 3: Sun 04:00)

- **Celestial Namesake**: Hydra (Pluto III, outer moon of Pluto)
- **Hardware**: Lenovo ThinkCentre M920q Tiny (Intel Core CPU, vPro / Intel UHD 630 Graphics)
- **Memory**: 16 GB DDR4 SODIMM
- **Storage**: Ephemeral tmpfs root with Disko Btrfs on NVMe (`/dev/nvme0n1`)
- **Bootloader**: Limine UEFI
- **Role**: K3s High-Availability Control-Plane Master (`serverAddr = "https://pluto:6443"`)
- **Preservation & Secrets**: Preserves `/persist`, `/var/lib/rancher`, `/etc/rancher`; Agenix secrets enabled.
- **Maintenance Schedule**: Weekly automated upgrade and reboot every Sunday at **04:00** (`rebootWindow`: 04:00–04:20).
- **Networking & Firewall**: Ports identical to Pluto and Charon (22, 6443, 2379, 2380, 10250, UDP 8472).
