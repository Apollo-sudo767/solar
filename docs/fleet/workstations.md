# Workstations & Portable Devices 🚀

This section covers the primary everyday workstations and mobile laptops in the Solar fleet.

______________________________________________________________________

## 🖥️ 1. Mars (Primary Workstation)

**Mars** is the primary high-performance desktop workstation, built for heavy software engineering, content creation, game streaming, and competitive esports.

- **Hardware Profile**: AMD CPU + Nvidia GPU (using open kernel modules).
- **Desktop Environment**: **Niri** scrollable tiling Wayland compositor with **ReGreet** GTK4 login manager and **Stylix Sky** theme.
- **Display Matrix**:
  - Primary: 27" 1440p @ 180Hz (Horizontal, VRR/G-Sync enabled).
  - Secondary: 27" 1080p @ 165Hz (Vertical orientation for coding and documents, VRR enabled).
- **Storage Topology**: Wipe-on-boot ephemeral `tmpfs` root with Disko Btrfs subvolumes across:
  - 2x NVMe SSD Speed Pool (`/persist` for stateful files, `.config`, and home).
  - 2x HDD Bulk Storage Pool (`/persist/bulk` for SteamBulk and media).
- **Workloads & Toolchains**:
  - **Competitive TF2 Suite & Mumble**: Low-latency 66-tick net rates, null-cancelling movement, Valve demo recording, VPKEdit, and `tf2-rcon`.
  - **Steam & Gamescope**: ProtonUp-Qt, MangoHud, GameMode scheduler optimization.
  - **Media Production**: DaVinci Resolve Studio video editing and OBS Studio with VAAPI & PipeWire capture.
  - **Game Streaming**: Sunshine GameStream host server (port 48000) for Moonlight streaming to portable devices.
  - **Peripherals**: Wooting analog keyboard, Xbox and Nintendo controller integration.

______________________________________________________________________

## 💻 2. Mercury (Portable Laptop)

**Mercury** is a lightweight, high-efficiency Linux laptop optimized for mobile software engineering and maximum battery endurance.

- **Hardware Profile**: Intel CPU + Intel Iris Xe iGPU.
- **Desktop Environment**: **Niri** scrollable tiling Wayland compositor with **Stylix Sky** theme.
- **Storage Topology**: Wipe-on-boot `tmpfs` root with single NVMe Btrfs persistent storage (`/persist`).
- **Power & Mobility**:
  - Aggressive battery and power-saving profiles via TLP and powertop.
  - Multi-touch trackpad gesture navigation in Niri.
  - Persistent WiFi network state preserved across reboots.
- **Workloads**: Terminal toolkit (Ghostty, Helix, Antigravity, Fastfetch), Firefox Nightly, and full remote access to Mars and Venus via Tailscale.

______________________________________________________________________

## 🍏 3. Phobos (Apple Silicon MacBook)

**Phobos** is an Apple Silicon MacBook orchestrated seamlessly through `nix-darwin` and Home Manager.

- **Hardware Profile**: Apple Silicon (`aarch64-darwin`).
- **Management Model**: Pure declarative `nix-darwin` orchestration without manual dotfile management.
- **Homebrew Integration**: Declarative Homebrew bundle integration for macOS-exclusive GUI applications.
- **System Defaults**: System-level macOS configurations including system-wide Dark Mode, auto-hiding dock, natural scrolling, and key repeat acceleration.
- **Workloads**: Ghostty GPU terminal, Helix modal editor, Antigravity AI coding assistant, Logseq, Raycast, and AP-Office suite.
