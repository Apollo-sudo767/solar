# Virtual Reality Suite 🥽

Solar features a unified, cross-platform Virtual Reality suite (`myFeatures.programs.media.vr`) supporting tethered PCVR and wireless/standalone headsets like the Meta Quest series.

______________________________________________________________________

## 🎮 Headset Architecture

| Headset Type | Supported Hardware | Primary Runtime / Streamer |
| :--- | :--- | :--- |
| **Meta Quest (Wired USB)** | Quest 1, Quest 2, Quest 3, Quest Pro | **WiVRn** or **ALVR** via ADB Reverse Port Forwarding |
| **Wireless Standalone** | Quest, Pico 4, Apple Vision Pro | **WiVRn** (UDP port 9757) or **ALVR** (UDP port 9944) over WiFi 6 |
| **Tethered PCVR** | Valve Index, HTC Vive, Oculus Rift | **Monado** OpenXR + `hardware.steam-hardware` |

______________________________________________________________________

## ⚡ Key Components

### 1. WiVRn (Wireless VR Network Streamer)

- Direct hardware OpenXR streaming server.
- Automatically exports `/etc/openxr/1/active_runtime.json` for Steam Pressure Vessel and Proton compatibility.
- Seamless OpenVR bridge via **xrizer** (`setup-wivrn-openvr`).

### 2. Wired Quest Reverse Port-Forwarding

- Integrated systemd user services (`wivrn-quest-wired` / `alvr-quest-wired`) that automatically detect USB-connected Quest headsets and establish low-latency ADB reverse tunnels (`adb reverse tcp:9757 tcp:9757`).

### 3. Monado OpenXR Runtime

- Fully open-source OpenXR runtime for Linux supporting lighthouse tracking via `libsurvive`.

### 4. SideQuest & ADB Integration

- Built-in `sidequest` manager and automatic `adbusers` group configuration for headset management.
