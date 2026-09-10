# Fleet Overview 🪐

Solar orchestrates an entire constellation of 15 machines across physical workstations, laptops, gaming rigs, storage arrays, cloud servers, and testbeds.

______________________________________________________________________

## 🗺️ The Constellation Map

| Host | Form Factor | Architecture | Primary Role | Platform & UI | Storage Tier |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`sol`** | Storage Server (NAS) | `x86_64-linux` | Central Fleet ZFS NAS & Storage Hub | Headless Server | Ephemeral `tmpfs` + 1x NVMe + 2x HDD (ZFS Mirror `tank`) |
| **`mars`** | Desktop Workstation | `x86_64-linux` | Primary Workstation & Esports Rig | Niri (Sky Theme) | Ephemeral `tmpfs` + 2x NVMe + 2x HDD |
| **`mercury`** | Laptop | `x86_64-linux` | Portable Development | Niri (Sky Theme) | Ephemeral `tmpfs` + 1x NVMe |
| **`phobos`** | MacBook | `aarch64-darwin` | macOS Mobility & Apple Silicon | macOS + Homebrew | APFS Encrypted |
| **`elara`** | Gaming Rig | `x86_64-linux` | 4K Gaming & Live Streaming | KDE Plasma 6 (Strawberry) | Standard Btrfs + 1x SSD |
| **`europa`** | VR Workstation | `x86_64-linux` | VR Streaming & Video Production | KDE Plasma 6 (Forest) | Standard Btrfs + 1x SSD |
| **`amalthea`** | Handheld Console | `x86_64-linux` | Portable Steam Gaming | Steam Big Picture (Gamescope) | Standard Btrfs + eMMC/SD |
| **`pluto`** | Mini PC (Beelink) | `x86_64-linux` | Pluto Cluster Bootstrap Master & Game Host | Headless / K3s HA | Ephemeral `tmpfs` + NVMe |
| **`styx`** | Laptop (ThinkPad) | `x86_64-linux` | Pluto Cluster Control Plane Master | Headless / K3s HA | Ephemeral `tmpfs` + NVMe |
| **`hydra`** | Tiny PC (ThinkCentre) | `x86_64-linux` | Pluto Cluster Control Plane & Media Transcoder | Headless / K3s HA | Ephemeral `tmpfs` + NVMe |
| **`sol`** | Storage Server | `x86_64-linux` | Central Fleet ZFS NAS & Dynamic Storage Hub | Headless Server | ZFS Pool `tank` + Multi-NIC |
| **`venus`** | Cloud Server | `x86_64-linux` | Web, Cloud Services & Game Servers | Headless Server | Standard Btrfs + 1x NVMe |
| **`pluto`** | Mini PC (Beelink EQR5) | `x86_64-linux` | K3s HA Bootstrap Master (Ryzen 7 5825U, 32GB RAM) | Headless Server | Ephemeral `tmpfs` + 1x NVMe |
| **`styx`** | Laptop (ThinkPad T14 Gen 2) | `x86_64-linux` | K3s HA Master Node 2 (16GB RAM) | Headless Server | Ephemeral `tmpfs` + 1x NVMe |
| **`hydra`** | Tiny PC (ThinkCentre M920q) | `x86_64-linux` | K3s HA Master Node 3 (i5-8500T, 16GB RAM) | Headless Server | Ephemeral `tmpfs` + 1x NVMe |
| **`io`** | Testbed | `x86_64-linux` | Experimental Desktop Testing | COSMIC Desktop (Space) | Standard Btrfs |

______________________________________________________________________

## 🏛️ Fleet Subsections

- **[Workstations & Portables](workstations.md)**: Details for **Mars**, **Mercury**, and **Phobos**.
- **[Gaming, VR & Rigs](gaming-vr.md)**: Details for **Elara**, **Europa**, and **Amalthea**.
- **[The Pluto Cluster](pluto-cluster.md)**: High-Availability K3s GitOps cluster (**Pluto**, **Styx**, **Hydra**, and storage **Sol**).
- **[Server & Cloud Infrastructure](servers.md)**: Multi-service web and game server **Venus**.
- **[Testbeds & Experimental](testbeds.md)**: Experimental COSMIC workstation **Io**.

______________________________________________________________________

## 🧭 Navigation & Next Steps

- **[Browse The Pluto Cluster Documentation](pluto-cluster.md)** ➔
- **[Explore Workstations & Laptops](workstations.md)** ➔
- **[Return to Documentation Overview](../index.md)** ➔
