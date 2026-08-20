# Fleet Overview 🪐

Solar manages a constellation of specialized machines, each named after planets and moons in the solar system.

______________________________________________________________________

## 🌕 The Jupiter Moon Stack *(Self-Contained Storage & Nodes)*

Configured with **Universal Disko**, **LUKS Encryption**, **Btrfs** (`zstd` compression, `noatime`, auto-scrubbing), and **zero dependencies on private secret repositories**.

| Host | Celestial Namesake | Role & Hardware | Key Highlights |
| :--- | :--- | :--- | :--- |
| **`thebe`** | Inner Moon (Jupiter XIV) | **Intel Mac Mini**<br>• Intel CPU & iGPU<br>• Apple SMC sensors | UEFI `limine` bootloader, Disko LUKS + Btrfs on SATA/NVMe SSD, `applesmc` thermal control, AppArmor, Tailscale. |
| **`ganymede`** | Galilean Moon (Jupiter III) | **Dedicated NAS**<br>• Fast NVMe OS cache<br>• Multi-HDD storage pool | Samba (SMB3 enforced), NFSv4, Avahi mDNS (`ganymede.local`), `smartd` health monitoring, weekly Btrfs auto-scrub. |
| **`callisto`** | Galilean Moon (Jupiter IV) | **General Storage & Backup**<br>• NVMe + HDD pool | Syncthing peer folder synchronization, backup utilities (Restic, Borg, Rclone, Rsync), `smartd` monitoring, weekly Btrfs scrub. |

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

## 🌐 Server & Cloud Infrastructure

| Host | Celestial Body | Role | Hosted Services |
| :--- | :--- | :--- | :--- |
| **`venus`** | Planet Venus | **Multi-Service Server**<br>• AMD CPU | Nginx reverse proxy with automated Dynamic DNS & Lego SSL certificates, Joplin Server, Zotero sync server, LanguageTool grammar server, dedicated Factorio & Minecraft servers. |
