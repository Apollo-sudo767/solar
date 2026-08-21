# Workstations & Portable Devices 🚀

______________________________________________________________________

## 🖥️ Mars (Main Workstation)

- **Architecture**: AMD CPU + Nvidia GPU.
- **Desktop Environment**: Niri scrollable tiling Wayland compositor, ReGreet greeter, Stylix Sky theme.
- **Storage Topology**: Wipe-on-boot `tmpfs` root with Disko Btrfs subvolumes across 2x NVMe speed pool + 2x HDD bulk pool.
- **Workloads**: Steam Proton with Gamescope, DaVinci Resolve video editing, Sunshine game streaming server, Wooting analog keyboard support.

______________________________________________________________________

## 💻 Mercury (Laptop)

- **Architecture**: Intel CPU + Intel iGPU.
- **Desktop Environment**: Niri scrollable Wayland compositor, ReGreet, Stylix Sky theme.
- **Storage Topology**: Wipe-on-boot `tmpfs` root with single NVMe Disko Btrfs pool.
- **Features**: Aggressive battery and power-saving profiles, trackpad gesture handling.

______________________________________________________________________

## 🎮 Elara (Gaming & Streaming Rig)

- **Architecture**: AMD CPU + Nvidia GPU.
- **Desktop Environment**: KDE Plasma, SDDM, Stylix Strawberry theme.
- **Workloads**: Steam Gamescope, Sunshine streaming server (port 48000), DaVinci Resolve, OBS Studio, Bitwarden.

______________________________________________________________________

## 🥽 Europa (VR & Media Workstation)

- **Architecture**: Intel CPU + Nvidia GPU.
- **Desktop Environment**: KDE Plasma, SDDM, Stylix Forest theme.
- **Workloads**: Meta Quest wired VR integration, video production and editing.

______________________________________________________________________

## 🕹️ Amalthea (Handheld Console)

- **Architecture**: Intel Atom z8350.
- **Interface**: Auto-logins directly into Steam Big Picture via Gamescope on KDE Plasma.
- **Optimizations**: Low-power Atom C-state stability kernel parameters, Limine bootloader, SD card game automounting.

______________________________________________________________________

## 🍏 Phobos (MacBook)

- **Architecture**: Apple Silicon (`aarch64-darwin`).
- **Management**: Pure `nix-darwin` orchestration.
- **Features**: Homebrew bundle integration, macOS system defaults (Dark mode, auto-hide dock), Logseq, Raycast, iTerm2, AP-Office.

______________________________________________________________________

## 🧪 Io (Testbed)

- **Architecture**: Linux x86_64.
- **Desktop Environment**: Rust-based COSMIC Desktop Environment & COSMIC Greeter, Stylix Space theme.
