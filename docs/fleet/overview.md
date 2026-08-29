# Fleet Overview 🪐

Solar orchestrates an entire constellation of 11 machines across physical workstations, laptops, gaming rigs, storage arrays, cloud servers, and testbeds.

______________________________________________________________________

## 🗺️ The Constellation Map

| Host | Form Factor | Architecture | Primary Role | Platform & UI | Storage Tier |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`mars`** | Desktop Workstation | `x86_64-linux` | Primary Workstation & Esports Rig | Niri (Sky Theme) | Ephemeral `tmpfs` + 2x NVMe + 2x HDD |
| **`mercury`** | Laptop | `x86_64-linux` | Portable Development | Niri (Sky Theme) | Ephemeral `tmpfs` + 1x NVMe |
| **`phobos`** | MacBook | `aarch64-darwin` | macOS Mobility & Apple Silicon | macOS + Homebrew | APFS Encrypted |
| **`elara`** | Gaming Rig | `x86_64-linux` | 4K Gaming & Live Streaming | KDE Plasma 6 (Strawberry) | Standard Btrfs + 1x SSD |
| **`europa`** | VR Workstation | `x86_64-linux` | VR Streaming & Video Production | KDE Plasma 6 (Forest) | Standard Btrfs + 1x SSD |
| **`amalthea`** | Handheld Console | `x86_64-linux` | Portable Steam Gaming | Steam Big Picture (Gamescope) | Standard Btrfs + eMMC/SD |
| **`thebe`** | Mac Mini Node | `x86_64-linux` | Compact Desktop / Server Node | Headless / Limine | Standard Btrfs + LUKS2 |
| **`ganymede`** | Storage Server | `x86_64-linux` | Dedicated NAS (Samba / NFS) | Headless Server | Standard Btrfs + 1x NVMe + 2x HDD |
| **`callisto`** | Backup Server | `x86_64-linux` | Backup & Syncthing Node | Headless Server | Standard Btrfs + 1x NVMe + 1x HDD |
| **`venus`** | Cloud Server | `x86_64-linux` | Web, Cloud Services & Game Servers | Headless Server | Standard Btrfs + 1x NVMe |
| **`io`** | Testbed | `x86_64-linux` | Experimental Desktop Testing | COSMIC Desktop (Space) | Standard Btrfs |

______________________________________________________________________

## 🏛️ Fleet Subsections

- **[Workstations & Portables](workstations.md)**: Details for **Mars**, **Mercury**, and **Phobos**.
- **[Gaming, VR & Rigs](gaming-vr.md)**: Details for **Elara**, **Europa**, and **Amalthea**.
- **[The Jupiter Moon Stack](jupiter-stack.md)**: Details for standalone storage nodes **Thebe**, **Ganymede**, and **Callisto**.
- **[Server & Cloud Infrastructure](servers.md)**: Multi-service web and game server **Venus**.
- **[Testbeds & Experimental](testbeds.md)**: Experimental COSMIC workstation **Io**.
