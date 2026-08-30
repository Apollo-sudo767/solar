# Role & Workflow Suites 📦

Solar provides pre-packaged domain suites located in [`modules/suites/`](file:///Users/apollo/src/solar/modules/suites) that cater to distinct machine roles, engineering workflows, and specialized workloads.

______________________________________________________________________

## 🗂️ Available Role & Workflow Suites

| Suite | Option Path | Primary Scope & Included Components |
| :--- | :--- | :--- |
| **Workstation** | `myFeatures.suites.workstation` | **Full Development & Desktop Stack**: Ghostty, Helix, Git, Fastfetch, NH, Antigravity, Direnv, Nix-LD, Firefox, Bitwarden, Social (Vesktop), PipeWire Audio, Flatpak, XDG Portals, Udisks2. |
| **Gaming** | `myFeatures.suites.gaming` | **Esports & Gaming Stack**: 64-bit Steam with Proton installer, GameScope, Xbox/Nintendo controller drivers, Mumble VoIP with Wayland push-to-talk, Team Fortress 2 suite, PipeWire audio. |
| **Creator** | `myFeatures.suites.creator` | **Media Production & Creation**: DaVinci Resolve Studio, OBS Studio (VAAPI & PipeWire capture), VLC Media Player, Ani-CLI, multimedia codecs. |
| **Streaming** | `myFeatures.suites.streaming` | **Game & Screen Streaming Host**: Sunshine streaming host daemon (port 48000), Moonlight streaming client. |
| **Productivity** | `myFeatures.suites.productivity` | **Office & Document Authoring**: AP-Office document authoring suite, CUPS printing daemon subsystem. |
| **Hardened** | `myFeatures.suites.hardened` | **Security Hardening**: AppArmor Mandatory Access Control profiles, Systemd OOMD out-of-memory daemon. |
| **Networking** | `myFeatures.suites.networking` | **Mesh VPN & DNS**: Tailscale mesh networking, Systemd-Resolved DNS resolution and caching. |
| **Laptop** | `myFeatures.suites.laptop` | **Mobile Power & Connectivity**: TLP / battery thresholds, Bluetooth management, WiFi network state, multi-touch trackpad gestures, idle screen locker daemon. |
| **Server** | `myFeatures.suites.server` | **Headless Infrastructure**: Hardened SSH, Tailscale, Lix implementation, automated Nix garbage collection, modern interactive shell (Zsh/Starship), Helix, NH, Udisks2. |
| **Virtualization** | `myFeatures.suites.virtualization` | **Containers & Hypervisors**: Podman / Docker container runtime, QEMU/KVM, Libvirt virtualization daemon, Virt-Manager GUI. |
| **Development** | `myFeatures.suites.development` | **Advanced Toolchain**: Helix modal editor, Git, Direnv, Nix-LD dynamic linker, Antigravity AI coding assistant, Fastfetch, NH CLI. |
| **Darwin Workstation** | `myFeatures.suites.darwinWorkstation` | **macOS Workstation**: Declarative Homebrew bundles, Ghostty, Helix, Antigravity, Fastfetch, Direnv, AP-Office suite. |

______________________________________________________________________

## 🔍 Detailed Suite Breakdowns

### 1. Workstation Suite (`suites.workstation`)
The standard foundation for physical desktop workstations (**Mars**, **Mercury**, **Elara**, **Europa**, **Io**).
```nix
myFeatures.suites.workstation.enable = true;
```
- **CLI & Terminals**: Ghostty GPU terminal, modern Zsh + Starship prompt, Helix editor, Fastfetch, NH management helper.
- **Developer Tools**: Git, Direnv, Nix-LD dynamic loader, Antigravity AI coding pair.
- **Everyday Desktop Tools**: Firefox web browser, Bitwarden password manager, Vesktop/Discord.
- **Core Subsystems**: PipeWire low-latency audio, XDG Desktop Portals, Flatpak application runtime, Udisks2 auto-mounting.

### 2. Gaming Suite (`suites.gaming`)
Optimized for low-latency desktop and handheld gaming rigs (**Mars**, **Elara**, **Europa**, **Amalthea**).
```nix
myFeatures.suites.gaming.enable = true;
```
- **Steam Ecosystem**: Native Steam 64-bit client, ProtonUp-Qt installer, GameScope micro-compositor.
- **Hardware Peripherals**: Kernel modules and udev rules for Xbox One/Series controllers, Nintendo Switch Pro controllers, and DualSense.
- **Voice & Multiplayer**: Mumble VoIP with global Wayland push-to-talk, Team Fortress 2 competitive suite.

### 3. Creator Suite (`suites.creator`)
For high-resolution video editing, content capture, and media playback.
```nix
myFeatures.suites.creator.enable = true;
```
- **DaVinci Resolve Studio**: GPU-accelerated video editing with OpenCL/CUDA acceleration.
- **OBS Studio**: High-bitrate screen recording and live streaming with PipeWire audio/video capture.
- **Media Players**: VLC, Ani-CLI, and ffmpeg codecs.

### 4. Server Suite (`suites.server`)
For headless bare-metal servers, NAS nodes, and cloud instances (**Ganymede**, **Callisto**, **Thebe**, **Venus**).
```nix
myFeatures.suites.server.enable = true;
```
- **Zero GUI Overhead**: No X11/Wayland daemons or graphical packages.
- **Security**: Key-only OpenSSH daemon, AppArmor MAC profiles, Fail2ban protection.
- **Mesh Connectivity**: Tailscale WireGuard mesh node automatically registered.
- **Maintenance**: Automated daily Nix store garbage collection and Lix package engine.

### 5. Laptop Suite (`suites.laptop`)
For mobile laptops requiring battery longevity and physical convenience (**Mercury**, **Europa**).
```nix
myFeatures.suites.laptop.enable = true;
```
- **Power Management**: Aggressive power saving, battery charge thresholds, TLP daemon.
- **Connectivity**: NetworkManager WiFi state retention, Bluetooth pairing.
- **Input & Display**: Multi-touch trackpad natural scrolling, automatic idle screen locking and display sleep.
