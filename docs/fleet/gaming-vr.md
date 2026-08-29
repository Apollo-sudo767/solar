# Gaming, VR & Rigs 🎮

This section covers dedicated gaming PCs, virtual reality workstations, and handheld consoles in the Solar constellation.

______________________________________________________________________

## 🎮 1. Elara (Gaming & Live Streaming Rig)

**Elara** is a high-powered desktop dedicated to 4K gaming, high-fps esports, and live multimedia broadcasting.

- **Hardware Profile**: AMD Ryzen CPU + Nvidia GeForce GPU.
- **Desktop Environment**: **KDE Plasma 6** on Wayland with **SDDM** greeter and **Stylix Strawberry** theme.
- **Display Setup**: 4K UHD display with HDR and Variable Refresh Rate (VRR / G-Sync).
- **Workloads & Capabilities**:
  - **Steam with Gamescope**: Hardware-accelerated Wayland micro-compositor sessions.
  - **Streaming & Broadcasting**: OBS Studio with hardware NVENC / VAAPI acceleration and PipeWire source capture.
  - **Sunshine Streaming Server**: Remote 4K 120fps low-latency game streaming over local LAN and Tailscale mesh.
  - **DaVinci Resolve**: Hardware-accelerated CUDA video editing.
  - **Prism Launcher**: High-performance modded Minecraft instances with Temurin JDK 21/17.

______________________________________________________________________

## 🥽 2. Europa (VR & Media Workstation)

**Europa** is a specialized virtual reality and content production workstation engineered for low-latency tethered and wireless VR headsets.

- **Hardware Profile**: Intel Core CPU + Nvidia RTX GPU.
- **Desktop Environment**: **KDE Plasma 6** on Wayland with **SDDM** and **Stylix Forest** theme.
- **Virtual Reality Suite**:
  - **Meta Quest Wired Streaming**: Automated USB ADB reverse port-forwarding daemons for low-latency tethered streaming (`alvr-quest-wired` / `wivrn-quest-wired`).
  - **WiVRn OpenXR Server**: Direct hardware OpenXR streaming runtime with SteamVR xrizer bridge.
  - **ALVR (Air Light VR)**: Open-source PC VR streamer for standalone headsets over WiFi 6 / 5GHz.
  - **Monado**: OpenXR runtime service for tethered PCVR headsets.
  - **SideQuest**: Headset app manager and ADB sideloading.
- **Workloads**: High-fidelity VR simulation, SteamVR gaming, and Blender / DaVinci rendering.

______________________________________________________________________

## 🕹️ 3. Amalthea (Handheld Gaming Console)

**Amalthea** is an ultra-compact, portable handheld gaming console built on the Intel Atom architecture.

- **Hardware Profile**: Intel Atom x5-Z8350 CPU + Intel HD Graphics.
- **Interface**: Auto-logins directly into **Steam Big Picture Mode** inside a customized Gamescope micro-compositor session on KDE Plasma.
- **Low-Power Optimizations**:
  - Specific C-state kernel arguments preventing Atom processor lockups.
  - Limine bootloader with fast splash screen.
  - Automatic SD card partition mounting for expandable game storage (`/mnt/games`).
- **Workloads**: Retro emulation, 2D indie titles, and Moonlight client streaming games from Mars and Elara over WiFi.
