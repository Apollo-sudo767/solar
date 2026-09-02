# ☀️ Definitive Flake Toggle & Option Reference

Welcome to the definitive, complete catalog of all **538 declarative toggles and configuration options** available across the Solar flake.

All options live under the unified `myFeatures` hierarchy (`modules/`) and can be declared in any host configuration leaf (`modules/hosts/<hostname>/default.nix`).

______________________________________________________________________

## 🧭 Table of Contents

- [🌲 Suites: Role & Workflow](#suites-role-workflow)
- [🖥️ Suites: Desktop Environments & Compositors](#suites-desktops)
- [💻 Programs: Terminal & Developer Tools](#programs-terminal)
- [🌐 Programs: Web Browsers](#programs-browsers)
- [🎮 Programs: Gaming & Media](#programs-media)
- [💬 Programs: Utilities & Social](#programs-utilities)
- [📚 Programs: Office & Publishing](#programs-office)
- [🪟 Platforms: Window Managers & Compositors](#platforms-desktops)
- [📊 Platforms: Desktop Addons & Panels](#platforms-addons)
- [🎨 Platforms: Styling & Themes](#platforms-styling)
- [🚀 Core: Bootloader & Kernel](#core-boot)
- [🔒 Core: Security & Secrets](#core-security)
- [💾 Core: System, Disko & Users](#core-system)
- [🐚 Core: Shell & CLI](#core-shell)
- [❄️ Core: Nix Engine & Channels](#core-nix)
- [⚡ Hardware: CPU & GPU Drivers](#hardware-cpu-gpu)
- [🎮 Hardware: Input & Controllers](#hardware-input)
- [🔋 Hardware: Peripherals & Mobile](#hardware-peripherals)
- [🖥️ Hardware: System Peripherals](#hardware-system)
- [🖨️ Services: Hardware & Storage](#services-hardware)
- [🔊 Services: Multimedia & Audio](#services-multimedia)
- [🌐 Services: Networking & DNS](#services-networking)
- [📦 Services: System Daemons](#services-system)
- [🖧 Services: Server Stack & Self-Hosted](#services-servers)
- [🍎 Darwin (macOS) Specifics](#darwin-system)

______________________________________________________________________

## 💡 How Options & Suites Work in Solar

1. **Atomic Toggles**: Every feature option can be turned on or off individually.
1. **Suites with `lib.mkDefault`**: Suites enable a bundle of features using `lib.mkDefault`, allowing any individual host leaf to override any specific sub-option.
1. **Minimal Modes**: Minimal suite options and the `minimal` toggle enable lightweight / TUI variants (`vesktop`, `spotify-player`, lightweight office, essential CLI tools) instead of heavy GUI suites.

```nix
# Example: modules/hosts/mars/default.nix
myFeatures = {
  # Enable high-level suites
  suites = {
    workstation.enable = true;
    gaming.enable = true;
    minimal.enable = false; # Or enable minimal suite for lightweight tools
  };

  # Override any specific toggle
  programs.utilities.social = {
    vesktop.enable = true;
    spotify_player.enable = true;
    spotify.enable = false; # Disable Spotify GUI
  };
};
```

______________________________________________________________________

<a id="suites-role-workflow"></a>

## 🌲 Suites: Role & Workflow

> High-level composite suites bundling related applications, subsystems, and services with `lib.mkDefault`.

**Total Options**: 93

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.suites.creator.aniCli.enable` | bool | `true` | Enable Ani-CLI anime streaming CLI. |
| `myFeatures.suites.creator.davinci.enable` | bool | `true` | Enable DaVinci Resolve Studio video editor. |
| `myFeatures.suites.creator.enable` | bool | `false` | Whether to enable Content Creation & Media Production Suite (DaVinci Resolve, OBS Studio, VLC, Ani-CLI, Media Tools). |
| `myFeatures.suites.creator.mediaTools.enable` | bool | `true` | Enable universal media tools, codecs, and MPV. |
| `myFeatures.suites.creator.obs.enable` | bool | `true` | Enable OBS Studio screen recorder and streaming suite. |
| `myFeatures.suites.creator.vlc.enable` | bool | `true` | Enable VLC media player. |
| `myFeatures.suites.darwinWorkstation.enable` | bool | `false` | Whether to enable Darwin (macOS) Workstation Suite. |
| `myFeatures.suites.darwinWorkstation.homebrew.enable` | bool | `true` | Enable declarative Homebrew bundle integration. |
| `myFeatures.suites.darwinWorkstation.office.enable` | bool | `true` | Enable AP-Office suite on Darwin. |
| `myFeatures.suites.darwinWorkstation.terminal.antigravity` | bool | `true` | Enable Antigravity AI pair programmer. |
| `myFeatures.suites.darwinWorkstation.terminal.direnv` | bool | `true` | Enable Direnv automatic environment switcher. |
| `myFeatures.suites.darwinWorkstation.terminal.enable` | bool | `true` | Enable macOS terminal and developer tools. |
| `myFeatures.suites.darwinWorkstation.terminal.fastfetch` | bool | `true` | Enable Fastfetch system visualizer. |
| `myFeatures.suites.darwinWorkstation.terminal.helix` | bool | `true` | Enable Helix modal editor. |
| `myFeatures.suites.darwinWorkstation.utilities.filemanager` | bool | `true` | Enable file manager. |
| `myFeatures.suites.development.antigravity.enable` | bool | `true` | Enable Antigravity AI pair programming assistant. |
| `myFeatures.suites.development.direnv.enable` | bool | `true` | Enable Direnv automatic environment switching. |
| `myFeatures.suites.development.enable` | bool | `false` | Whether to enable Advanced Development Suite (Helix, Git, Direnv, Nix-LD, Antigravity, Fastfetch). |
| `myFeatures.suites.development.fastfetch.enable` | bool | `true` | Enable Fastfetch system visualizer. |
| `myFeatures.suites.development.git.enable` | bool | `true` | Enable Git version control. |
| `myFeatures.suites.development.helix.enable` | bool | `true` | Enable Helix modal text editor. |
| `myFeatures.suites.development.nh.enable` | bool | `true` | Enable NH Nix CLI helper. |
| `myFeatures.suites.development.nixLd.enable` | bool | `true` | Enable nix-ld dynamic binary loader. |
| `myFeatures.suites.gaming.audio.enable` | bool | `true` | Enable PipeWire low-latency gaming audio. |
| `myFeatures.suites.gaming.controllers.enable` | bool | `true` | Enable gamepad controller subsystem. |
| `myFeatures.suites.gaming.controllers.nintendo` | bool | `true` | Enable Nintendo Switch Pro controller support. |
| `myFeatures.suites.gaming.controllers.playstation` | bool | `false` | Enable PlayStation DualSense controller drivers. |
| `myFeatures.suites.gaming.controllers.xbox` | bool | `true` | Enable Xbox One & Series controller drivers and xpadneo. |
| `myFeatures.suites.gaming.enable` | bool | `false` | Whether to enable Gaming Suite (Steam, GameScope, Controllers, Audio & Communication). |
| `myFeatures.suites.gaming.games.mcpelauncher` | bool | `false` | Enable MCPELauncher (Minecraft Bedrock) via Flatpak. |
| `myFeatures.suites.gaming.games.prism` | bool | `false` | Enable Prism Minecraft launcher. |
| `myFeatures.suites.gaming.games.sober` | bool | `false` | Enable Sober (Roblox) via Flatpak. |
| `myFeatures.suites.gaming.games.tf2` | bool | `true` | Enable Team Fortress 2 competitive suite. |
| `myFeatures.suites.gaming.social.enable` | bool | `true` | Enable social communication suite (Vesktop & Spotify Player). |
| `myFeatures.suites.gaming.social.minimal` | bool | `true` | Use minimal/lightweight social suite clients. |
| `myFeatures.suites.gaming.steam.enable` | bool | `true` | Enable native Steam gaming platform. |
| `myFeatures.suites.gaming.steam.gamescope` | bool | `false` | Enable GameScope micro-compositor wrapper. |
| `myFeatures.suites.gaming.steam.protonInstaller` | bool | `true` | Enable ProtonUp-Qt compatibility tool manager. |
| `myFeatures.suites.gaming.voip.mumble` | bool | `true` | Enable Mumble low-latency VoIP client with Wayland push-to-talk. |
| `myFeatures.suites.hardened.appArmor.enable` | bool | `true` | Enable AppArmor kernel module and profile enforcement. |
| `myFeatures.suites.hardened.enable` | bool | `false` | Whether to enable Security Hardening Suite (AppArmor, OOMD). |
| `myFeatures.suites.hardened.oomd.enable` | bool | `true` | Enable Systemd OOMD memory pressure monitoring daemon. |
| `myFeatures.suites.laptop.battery.enable` | bool | `true` | Enable battery charge thresholds and TLP power profile optimizations. |
| `myFeatures.suites.laptop.bluetooth.enable` | bool | `true` | Enable Bluetooth peripheral support. |
| `myFeatures.suites.laptop.enable` | bool | `false` | Whether to enable Laptop Suite (Battery, Bluetooth, WiFi, Trackpad & Power Management). |
| `myFeatures.suites.laptop.idle.enable` | bool | `true` | Enable automatic idle screen locking and display sleep. |
| `myFeatures.suites.laptop.trackpad.enable` | bool | `true` | Enable multi-touch trackpad gestures and natural scrolling. |
| `myFeatures.suites.laptop.wifi.enable` | bool | `true` | Enable WiFi network stack and state persistence. |
| `myFeatures.suites.minimal.browser.enable` | bool | `true` | Enable default browser (Firefox). |
| `myFeatures.suites.minimal.enable` | bool | `false` | Whether to enable Minimal Desktop & Tool Suite (Lightweight Desktop, Minimal Tools & TUI Clients). |
| `myFeatures.suites.minimal.media.enable` | bool | `true` | Enable lightweight media playback tools. |
| `myFeatures.suites.minimal.office.enable` | bool | `true` | Enable lightweight modular office tools (AbiWord, Gnumeric, PDFArranger, Evince). |
| `myFeatures.suites.minimal.social.enable` | bool | `true` | Enable minimal social suite (Vesktop + Spotify Player). |
| `myFeatures.suites.minimal.terminal.enable` | bool | `true` | Enable essential terminal and developer tools (Helix, Ghostty, Git, NH, Fastfetch, Direnv, Nix-LD). |
| `myFeatures.suites.minimal.utilities.enable` | bool | `true` | Enable core utilities (Bitwarden, File Manager). |
| `myFeatures.suites.networking.enable` | bool | `false` | Whether to enable Mesh Networking & Resolved DNS Suite (Tailscale, Resolved). |
| `myFeatures.suites.networking.resolved.enable` | bool | `true` | Enable Systemd-Resolved DNS resolution daemon. |
| `myFeatures.suites.networking.tailscale.enable` | bool | `true` | Enable Tailscale WireGuard mesh VPN node. |
| `myFeatures.suites.productivity.apOffice.enable` | bool | `true` | Enable complete AP-Office suite (LibreOffice, OnlyOffice, Zotero, Typst, Joplin, etc.) when mode is 'full'. |
| `myFeatures.suites.productivity.enable` | bool | `false` | Whether to enable Productivity & Office Suite (AP-Office / Lightweight Office, Printing). |
| `myFeatures.suites.productivity.lightweight.enable` | bool | `true` | Enable lightweight modular office tools (AbiWord, Gnumeric, PDFArranger, Evince) when mode is 'lightweight'. |
| `myFeatures.suites.productivity.mode` | `enum` | `"full"` | Productivity suite profile: 'full' for AP-Office (heavy document suite) or 'lightweight' for modular tools. |
| `myFeatures.suites.productivity.printing.enable` | bool | `true` | Enable CUPS printing daemon subsystem. |
| `myFeatures.suites.server.automation.enable` | bool | `true` | Enable automated Nix store garbage collection & maintenance. |
| `myFeatures.suites.server.enable` | bool | `false` | Whether to enable Server Suite (Headless, Hardened SSH, Tailscale, Automated maintenance). |
| `myFeatures.suites.server.lix.enable` | bool | `true` | Enable modern Lix package engine. |
| `myFeatures.suites.server.security.enable` | bool | `true` | Enable base security hardening profiles. |
| `myFeatures.suites.server.shell.enable` | bool | `true` | Enable interactive CLI shell environment (Zsh + Starship). |
| `myFeatures.suites.server.ssh.enable` | bool | `true` | Enable hardened key-only OpenSSH server daemon. |
| `myFeatures.suites.server.tailscale.enable` | bool | `true` | Enable Tailscale mesh node connectivity. |
| `myFeatures.suites.server.udisks2.enable` | bool | `true` | Enable Udisks2 storage daemon. |
| `myFeatures.suites.streaming.enable` | bool | `false` | Whether to enable Game & Display Streaming Host Suite (Sunshine). |
| `myFeatures.suites.streaming.port` | int | `48000` | Sunshine server port |
| `myFeatures.suites.virtualization.docker.enable` | bool | `true` | Enable Docker container engine. |
| `myFeatures.suites.virtualization.enable` | bool | `false` | Whether to enable Virtualization & Containers Suite (Podman, Docker, QEMU/KVM, Virt-Manager). |
| `myFeatures.suites.virtualization.libvirt.enable` | bool | `true` | Enable Libvirt/QEMU hypervisor subsystem. |
| `myFeatures.suites.workstation.browser.enable` | bool | `true` | Enable web browser (Firefox). |
| `myFeatures.suites.workstation.enable` | bool | `false` | Whether to enable Workstation Suite (Development tools, Terminal, Browsers, Utilities, Audio). |
| `myFeatures.suites.workstation.minimal` | bool | `true` | Enable minimal / lightweight variants for workstation tools. |
| `myFeatures.suites.workstation.services.audio` | bool | `true` | Enable PipeWire low-latency audio stack. |
| `myFeatures.suites.workstation.services.flatpak` | bool | `true` | Enable Flatpak application runtime. |
| `myFeatures.suites.workstation.services.udisks2` | bool | `true` | Enable Udisks2 storage auto-mounting daemon. |
| `myFeatures.suites.workstation.services.xdgPortals` | bool | `true` | Enable XDG Desktop Portals subsystem. |
| `myFeatures.suites.workstation.terminal.antigravity` | bool | `true` | Enable Antigravity AI pair programming agent. |
| `myFeatures.suites.workstation.terminal.direnv` | bool | `true` | Enable Direnv automatic environment switching. |
| `myFeatures.suites.workstation.terminal.enable` | bool | `true` | Enable developer terminal toolchain. |
| `myFeatures.suites.workstation.terminal.fastfetch` | bool | `true` | Enable Fastfetch system visualizer. |
| `myFeatures.suites.workstation.terminal.ghostty` | bool | `true` | Enable Ghostty GPU-accelerated terminal emulator. |
| `myFeatures.suites.workstation.terminal.git` | bool | `true` | Enable Git version control system. |
| `myFeatures.suites.workstation.terminal.helix` | bool | `true` | Enable Helix modal editor. |
| `myFeatures.suites.workstation.terminal.nh` | bool | `true` | Enable NH Nix CLI helper. |
| `myFeatures.suites.workstation.terminal.nix-ld` | bool | `true` | Enable nix-ld dynamic binary execution. |
| `myFeatures.suites.workstation.utilities.bitwarden` | bool | `true` | Enable Bitwarden credential manager. |
| `myFeatures.suites.workstation.utilities.filemanager` | bool | `true` | Enable desktop & terminal file managers. |
| `myFeatures.suites.workstation.utilities.social` | bool | `true` | Enable social communication suite (Vesktop & Spotify Player). |

______________________________________________________________________

<a id="suites-desktops"></a>

## 🖥️ Suites: Desktop Environments & Compositors

> Complete desktop environment and window manager suites bundled with display managers, default file managers, bars, and audio.

**Total Options**: 48

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.suites.desktops.awesome.enable` | bool | `false` | Whether to enable AwesomeWM Desktop Suite. |
| `myFeatures.suites.desktops.bspwm.enable` | bool | `false` | Whether to enable Bspwm Desktop Suite. |
| `myFeatures.suites.desktops.budgie.enable` | bool | `false` | Whether to enable Budgie Desktop Suite. |
| `myFeatures.suites.desktops.cinnamon.enable` | bool | `false` | Whether to enable Cinnamon Desktop Suite. |
| `myFeatures.suites.desktops.cosmic.audio.enable` | bool | `true` | Enable PipeWire low-latency audio. |
| `myFeatures.suites.desktops.cosmic.enable` | bool | `false` | Whether to enable COSMIC Desktop Suite. |
| `myFeatures.suites.desktops.cosmic.printing.enable` | bool | `true` | Enable CUPS printing daemon. |
| `myFeatures.suites.desktops.gnome.audio.enable` | bool | `true` | Enable PipeWire low-latency audio. |
| `myFeatures.suites.desktops.gnome.enable` | bool | `false` | Whether to enable GNOME Desktop Suite. |
| `myFeatures.suites.desktops.gnome.filemanager.enable` | bool | `true` | Enable Nautilus file manager. |
| `myFeatures.suites.desktops.gnome.filemanager.yazi` | bool | `true` | Enable Yazi terminal file manager. |
| `myFeatures.suites.desktops.gnome.printing.enable` | bool | `true` | Enable CUPS printing daemon. |
| `myFeatures.suites.desktops.hyprland.addons.swaync` | bool | `true` | Enable SwayNC notification center. |
| `myFeatures.suites.desktops.hyprland.addons.swayosd` | bool | `true` | Enable SwayOSD on-screen display for volume and brightness. |
| `myFeatures.suites.desktops.hyprland.addons.waybar` | bool | `true` | Enable Waybar status bar. |
| `myFeatures.suites.desktops.hyprland.audio.enable` | bool | `true` | Enable PipeWire low-latency audio. |
| `myFeatures.suites.desktops.hyprland.enable` | bool | `false` | Whether to enable Hyprland Desktop Suite (Hyprland + Waybar + SwayNC + ReGreet + Nautilus + Yazi + Audio + Portals). |
| `myFeatures.suites.desktops.hyprland.filemanager.enable` | bool | `true` | Enable Nautilus file manager. |
| `myFeatures.suites.desktops.hyprland.filemanager.yazi` | bool | `true` | Enable Yazi terminal file manager. |
| `myFeatures.suites.desktops.hyprland.xdgPortals.enable` | bool | `true` | Enable XDG desktop portals. |
| `myFeatures.suites.desktops.i3.enable` | bool | `false` | Whether to enable i3 X11 Desktop Suite (i3 + Picom + ReGreet + Nautilus + Yazi + Audio). |
| `myFeatures.suites.desktops.labwc.enable` | bool | `false` | Whether to enable Labwc Desktop Suite. |
| `myFeatures.suites.desktops.lxqt.enable` | bool | `false` | Whether to enable LXQt Desktop Suite. |
| `myFeatures.suites.desktops.mangowc.addons.swayosd` | bool | `true` | Enable SwayOSD on-screen display for volume and brightness. |
| `myFeatures.suites.desktops.mangowc.audio.enable` | bool | `true` | Enable PipeWire low-latency audio. |
| `myFeatures.suites.desktops.mangowc.enable` | bool | `false` | Whether to enable MangoWC Desktop Suite (MangoWC + ReGreet + Nautilus + Yazi + Audio + Portals). |
| `myFeatures.suites.desktops.mangowc.filemanager.enable` | bool | `true` | Enable Nautilus file manager. |
| `myFeatures.suites.desktops.mangowc.filemanager.yazi` | bool | `true` | Enable Yazi terminal file manager. |
| `myFeatures.suites.desktops.mangowc.xdgPortals.enable` | bool | `true` | Enable XDG desktop portals. |
| `myFeatures.suites.desktops.mate.enable` | bool | `false` | Whether to enable MATE Desktop Suite. |
| `myFeatures.suites.desktops.niri.enable` | bool | `false` | Whether to enable Niri Desktop Suite (Niri + Keybinds + ReGreet + Nautilus + Yazi + Audio + Portals). |
| `myFeatures.suites.desktops.niri.shell` | `enum` | `"noctalia-v5"` | Desktop shell/bar to enable with the Niri suite |
| `myFeatures.suites.desktops.plasma.audio.enable` | bool | `true` | Enable PipeWire low-latency audio. |
| `myFeatures.suites.desktops.plasma.enable` | bool | `false` | Whether to enable KDE Plasma Desktop Suite. |
| `myFeatures.suites.desktops.plasma.filemanager.enable` | bool | `true` | Enable Dolphin file manager. |
| `myFeatures.suites.desktops.plasma.filemanager.yazi` | bool | `true` | Enable Yazi terminal file manager. |
| `myFeatures.suites.desktops.plasma.printing.enable` | bool | `true` | Enable CUPS printing daemon. |
| `myFeatures.suites.desktops.qtile.enable` | bool | `false` | Whether to enable Qtile Desktop Suite. |
| `myFeatures.suites.desktops.sway.addons.swaync` | bool | `true` | Enable SwayNC notification center. |
| `myFeatures.suites.desktops.sway.addons.swayosd` | bool | `true` | Enable SwayOSD on-screen display for volume and brightness. |
| `myFeatures.suites.desktops.sway.addons.waybar` | bool | `true` | Enable Waybar status bar. |
| `myFeatures.suites.desktops.sway.audio.enable` | bool | `true` | Enable PipeWire low-latency audio. |
| `myFeatures.suites.desktops.sway.enable` | bool | `false` | Whether to enable Sway Desktop Suite (Sway + Waybar + SwayNC + ReGreet + Nautilus + Yazi + Audio + Portals). |
| `myFeatures.suites.desktops.sway.filemanager.enable` | bool | `true` | Enable Nautilus file manager. |
| `myFeatures.suites.desktops.sway.filemanager.yazi` | bool | `true` | Enable Yazi terminal file manager. |
| `myFeatures.suites.desktops.sway.xdgPortals.enable` | bool | `true` | Enable XDG desktop portals. |
| `myFeatures.suites.desktops.wayfire.enable` | bool | `false` | Whether to enable Wayfire Desktop Suite. |
| `myFeatures.suites.desktops.xfce.enable` | bool | `false` | Whether to enable XFCE Desktop Suite. |

______________________________________________________________________

<a id="programs-terminal"></a>

## 💻 Programs: Terminal & Developer Tools

> Command-line developer tools, editors, dynamic linkers, and shell assistants.

**Total Options**: 12

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.programs.terminal.antigravity.enable` | bool | `false` | Whether to enable Antigravity CLI Agent. |
| `myFeatures.programs.terminal.direnv.enable` | bool | `false` | Whether to enable direnv and nix-direnv auto-environment loader. |
| `myFeatures.programs.terminal.fastfetch.enable` | bool | `false` | Whether to enable fastfetch system info fetcher. |
| `myFeatures.programs.terminal.fastfetch.logoType` | `enum` | `"auto"` | Logo rendering backend. |
| `myFeatures.programs.terminal.ghostty.enable` | bool | `false` | Whether to enable Ghostty Terminal Emulator. |
| `myFeatures.programs.terminal.git.enable` | bool | `false` | Whether to enable Git Configuration. |
| `myFeatures.programs.terminal.git.userEmail` | `str` | `""` | Git user email |
| `myFeatures.programs.terminal.git.userName` | `str` | `""` | Git user name |
| `myFeatures.programs.terminal.git.users` | `attrsOf` | `{}` | Per-user git configuration overrides |
| `myFeatures.programs.terminal.helix.enable` | bool | `false` | Whether to enable Helix Editor. |
| `myFeatures.programs.terminal.nh.enable` | bool | `false` | Whether to enable nh (Nix Helper) integration. |
| `myFeatures.programs.terminal.nix-ld.enable` | bool | `false` | Whether to enable nix-ld helper for running unpatched binaries. |

______________________________________________________________________

<a id="programs-browsers"></a>

## 🌐 Programs: Web Browsers

> Web browsers including hardened Firefox profiles, Google Chrome, and Zen browser.

**Total Options**: 10

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.programs.browsers.chrome.default` | bool | `false` | Set Chrome/Chromium as the default browser |
| `myFeatures.programs.browsers.chrome.enable` | bool | `false` | Whether to enable Enables Chromium-based browsers. |
| `myFeatures.programs.browsers.chrome.googleChrome.enable` | bool | `false` | Whether to enable Use Google Chrome (proprietary). |
| `myFeatures.programs.browsers.chrome.ungoogled.enable` | bool | `false` | Whether to enable Use Ungoogled Chromium (privacy-hardened). |
| `myFeatures.programs.browsers.firefox.default` | bool | `true` | Set Firefox as the default browser |
| `myFeatures.programs.browsers.firefox.enable` | bool | `false` | Whether to enable Enables Firefox browser. |
| `myFeatures.programs.browsers.firefox.extensions.enable` | bool | `false` | Whether to enable Declarative force-installed extensions. |
| `myFeatures.programs.browsers.firefox.nightly.enable` | bool | `false` | Whether to enable Use Firefox Nightly binary. |
| `myFeatures.programs.browsers.zen.default` | bool | `false` | Set Zen Browser as the default browser |
| `myFeatures.programs.browsers.zen.enable` | bool | `false` | Whether to enable Zen Browser with Phanes Overrides. |

______________________________________________________________________

<a id="programs-media"></a>

## 🎮 Programs: Gaming & Media

> Steam ecosystem, GameScope, voice chat, media players, streaming tools, and video editors.

**Total Options**: 34

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.programs.media.ani-cli.enable` | bool | `false` | Whether to enable ani-cli CLI anime player. |
| `myFeatures.programs.media.davinci.enable` | bool | `false` | Whether to enable Enable Davinci-resolve. |
| `myFeatures.programs.media.gaming.enable` | bool | `false` | Whether to enable Gaming Suite (Steam + Prism Launcher). |
| `myFeatures.programs.media.media.enable` | bool | `false` | Whether to enable Apollo's Media Suite. |
| `myFeatures.programs.media.media.mpv.enable` | bool | `true` | Whether to enable MPV with 1440p GPU acceleration. |
| `myFeatures.programs.media.mcpelauncher.enable` | bool | `false` | Whether to enable MCPELauncher (Minecraft Bedrock Edition) via Flatpak. |
| `myFeatures.programs.media.mumble.enable` | bool | `false` | Whether to enable Mumble VoIP client. |
| `myFeatures.programs.media.mumble.overlay.enable` | bool | `true` | Enable Mumble in-game overlay support |
| `myFeatures.programs.media.obs.enable` | bool | `false` | Whether to enable OBS Studio. |
| `myFeatures.programs.media.prism.enable` | bool | `false` | Whether to enable Prism Launcher. |
| `myFeatures.programs.media.sober.enable` | bool | `false` | Whether to enable Sober (Roblox) via Flatpak. |
| `myFeatures.programs.media.steam.enable` | bool | `false` | Whether to enable Steam. |
| `myFeatures.programs.media.steam.gamescope.args` | `listOf` | `[]` | Arguments to pass to Gamescope |
| `myFeatures.programs.media.steam.gamescope.autoWrap` | bool | `true` | Automatically launch Steam inside Gamescope when running under Wayland/Niri |
| `myFeatures.programs.media.steam.gamescope.capSysNice` | bool | `false` | Enable CAP_SYS_NICE capability on gamescope wrapper (can cause bubblewrap/steam issues) |
| `myFeatures.programs.media.steam.gamescope.enable` | bool | `false` | Whether to enable Gamescope session / wrapper. |
| `myFeatures.programs.media.steam.gamescope.env` | `attrsOf` | `{}` | Environment variables for Gamescope |
| `myFeatures.programs.media.steam.protonInstaller.enable` | bool | `false` | Whether to enable GUI Proton installer (protonup-qt or protonup-gtk/protonplus). |
| `myFeatures.programs.media.steam.protonInstaller.flavor` | `enum` | `"auto"` | Which flavor of GUI proton installer to use (Qt/protonup-qt or GTK/protonplus). 'auto' selects based on compositor. |
| `myFeatures.programs.media.tf2.compHelper.enable` | bool | `true` | Install tf2-comp-setup CLI helper for autoexec generation, null-cancelling movement, and league configs |
| `myFeatures.programs.media.tf2.enable` | bool | `false` | Whether to enable Competitive Team Fortress 2 Suite & Toolchain. |
| `myFeatures.programs.media.tf2.logsHelper.enable` | bool | `true` | Install tf2-logs and tf2-demos match viewer and lookup CLI tools |
| `myFeatures.programs.media.tf2.mumble.enable` | bool | `true` | Enable Mumble voice client integration with positional audio and Wayland push-to-talk |
| `myFeatures.programs.media.tf2.rcon.enable` | bool | `true` | Enable RCON server administration tools (mcrcon and tf2-rcon CLI helper) |
| `myFeatures.programs.media.tf2.vpkTools.enable` | bool | `true` | Enable VPK package and custom HUD / hitsound editing tools (vpkedit) |
| `myFeatures.programs.media.vlc.enable` | bool | `false` | Whether to enable VLC Media Player. |
| `myFeatures.programs.media.vr.alvr.enable` | bool | `false` | Enable ALVR Air Light VR Streamer |
| `myFeatures.programs.media.vr.enable` | bool | `false` | Whether to enable Unified VR (Virtual Reality) Suite. |
| `myFeatures.programs.media.vr.monado.enable` | bool | `true` | Enable Monado OpenXR Runtime Service |
| `myFeatures.programs.media.vr.quest.enable` | bool | `true` | Enable support for Meta Quest headsets (Quest 1, 2, 3, Pro) |
| `myFeatures.programs.media.vr.quest.wired` | bool | `true` | Enable Quest 1/2/3 wired ALVR/WiVRn streaming over USB (ADB reverse connection) |
| `myFeatures.programs.media.vr.sidequest.enable` | bool | `true` | Enable SideQuest VR App Manager |
| `myFeatures.programs.media.vr.streamer` | `enum` | `"wivrn"` | Primary VR streaming provider for Quest / wireless headsets (WiVRn or ALVR) |
| `myFeatures.programs.media.vr.wired.enable` | bool | `true` | Enable support for Wired headsets (Valve Index, Vive, Rift, WMR) |
| `myFeatures.programs.media.vr.wireless.enable` | bool | `true` | Enable support for Wireless/Standalone headsets (Quest, Pico, Vision Pro) |
| `myFeatures.programs.media.vr.wivrn.enable` | bool | `true` | Enable WiVRn OpenXR Streaming Server |

______________________________________________________________________

<a id="programs-utilities"></a>

## 💬 Programs: Utilities & Social

> Social clients (Vesktop, Spotify Player), password managers, file managers, and note-taking tools.

**Total Options**: 29

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.programs.utilities.bitwarden.enable` | bool | `false` | Whether to enable Bitwarden Client. |
| `myFeatures.programs.utilities.filemanager.default` | bool | `true` | Set the enabled file manager as the default application for directory and file browsing across all apps. |
| `myFeatures.programs.utilities.filemanager.dolphin.enable` | bool | `false` | Enable KDE Dolphin File Manager. |
| `myFeatures.programs.utilities.filemanager.enable` | bool | `false` | Whether to enable File Manager module. |
| `myFeatures.programs.utilities.filemanager.nautilus.enable` | bool | `false` | Enable GNOME Nautilus File Manager. |
| `myFeatures.programs.utilities.filemanager.nemo.enable` | bool | `false` | Enable Cinnamon Nemo File Manager. |
| `myFeatures.programs.utilities.filemanager.pcmanfm.enable` | bool | `false` | Enable PCManFM File Manager. |
| `myFeatures.programs.utilities.filemanager.selection` | `enum` | `"dolphin"` | Select the active file manager to install and set as default. |
| `myFeatures.programs.utilities.filemanager.thunar.enable` | bool | `false` | Enable Thunar File Manager (XFCE). |
| `myFeatures.programs.utilities.filemanager.thunar.enablePlugins` | bool | `true` | Enable Thunar plugins (tumbler thumbnailer, archive plugin, volman, media-tags). |
| `myFeatures.programs.utilities.filemanager.yazi.enable` | bool | `false` | Enable Yazi TUI File Manager (can be enabled alongside GUI file managers). |
| `myFeatures.programs.utilities.lego.enable` | bool | `false` | Whether to enable lego. |
| `myFeatures.programs.utilities.logseq.enable` | bool | `false` | Whether to enable Logseq. |
| `myFeatures.programs.utilities.logseq.vaultPath` | `str` | `"Documents/Logseq"` | The relative path to your Logseq vault from home directory. |
| `myFeatures.programs.utilities.social.enable` | bool | `false` | Whether to enable Social Suite (Communication & Music). |
| `myFeatures.programs.utilities.social.minimal` | bool | `true` | Use minimal / lightweight clients (Vesktop + Spotify Player) instead of full GUI clients (Spotify GUI + WebCord). |
| `myFeatures.programs.utilities.social.spotify.enable` | bool | `false` | Enable Spotify GUI desktop client. |
| `myFeatures.programs.utilities.social.spotify_player.enable` | bool | `true` | Enable Spotify Player (TUI client). |
| `myFeatures.programs.utilities.social.vesktop.enable` | bool | `true` | Enable Vesktop Discord client. |
| `myFeatures.programs.utilities.social.webcord.enable` | bool | `false` | Enable WebCord Discord client. |
| `myFeatures.programs.utilities.spicetify.enable` | bool | `true` | Whether to enable Spicetify Integration. |
| `myFeatures.programs.utilities.spotify-player.enable` | bool | `false` | Whether to enable Spotify TUI client (spotify-player). |
| `myFeatures.programs.utilities.spotify.enable` | bool | `false` | Whether to enable Spotify GUI client. |
| `myFeatures.programs.utilities.spotify.gui.enable` | bool | `false` | Whether to enable Spotify GUI client. |
| `myFeatures.programs.utilities.spotify.tui.enable` | bool | `false` | Whether to enable Spotify TUI client (spotify-player). |
| `myFeatures.programs.utilities.spotify_player.enable` | bool | `false` | Whether to enable Spotify TUI client (spotify-player). |
| `myFeatures.programs.utilities.stylePackages.enable` | bool | `false` | Whether to enable Enables style packages for terminal. |
| `myFeatures.programs.utilities.vesktop.enable` | bool | `false` | Whether to enable Vesktop. |
| `myFeatures.programs.utilities.webcord.enable` | bool | `false` | Whether to enable WebCord. |

______________________________________________________________________

<a id="programs-office"></a>

## 📚 Programs: Office & Publishing

> Document authoring suites, modular office applications, typesetting (Typst/Pandoc), and bibliography tools.

**Total Options**: 68

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.programs.office.ap-office.defaultPdf` | bool | `true` | Set Zotero as the default PDF reader when AP Office is enabled. |
| `myFeatures.programs.office.ap-office.enable` | bool | `false` | Whether to enable AP Office Academic Suite (Joplin, Zotero, Pandoc, Typst, LanguageTool). |
| `myFeatures.programs.office.ap-office.joplin` | bool | `true` | Include Joplin core writing workspace & Markdown engine in AP Office Suite. |
| `myFeatures.programs.office.ap-office.languagetool` | bool | `true` | Include LanguageTool desktop proofreading & style linter in AP Office Suite. |
| `myFeatures.programs.office.ap-office.pandoc` | bool | `true` | Include Pandoc universal document converter in AP Office Suite. |
| `myFeatures.programs.office.ap-office.typst` | bool | `true` | Include Typst modern typesetting engine & PDF compiler in AP Office Suite. |
| `myFeatures.programs.office.ap-office.zotero` | bool | `true` | Include Zotero reference manager & PDF manager in AP Office Suite. |
| `myFeatures.programs.office.calligra.components.karbon` | bool | `true` | Calligra Karbon vector graphics editor. |
| `myFeatures.programs.office.calligra.components.plan` | bool | `true` | Calligra Plan project management tool. |
| `myFeatures.programs.office.calligra.components.sheets` | bool | `true` | Calligra Sheets spreadsheet application. |
| `myFeatures.programs.office.calligra.components.stage` | bool | `true` | Calligra Stage presentation manager. |
| `myFeatures.programs.office.calligra.components.words` | bool | `true` | Calligra Words text processing application. |
| `myFeatures.programs.office.calligra.enable` | bool | `false` | Whether to enable KDE Calligra Suite. |
| `myFeatures.programs.office.calligra.enableKrita` | bool | `false` | Install Krita raster graphics painter alongside Calligra. |
| `myFeatures.programs.office.joplin.cli` | bool | `false` | Whether to install the Joplin CLI client. |
| `myFeatures.programs.office.joplin.enable` | bool | `false` | Whether to enable Joplin Desktop & CLI note-taking application. |
| `myFeatures.programs.office.joplin.gui` | bool | `true` | Whether to install the Joplin Desktop client application. |
| `myFeatures.programs.office.joplin.plugins.bibtex` | bool | `true` | Install BibTeX plugin for Joplin desktop. |
| `myFeatures.programs.office.joplin.plugins.enable` | bool | `true` | Enable Joplin desktop plugins (Jopdoc, BibTeX, Outline, Rich Markdown). |
| `myFeatures.programs.office.joplin.plugins.jopdoc` | bool | `true` | Install Jopdoc export plugin for Joplin desktop. |
| `myFeatures.programs.office.joplin.plugins.outline` | bool | `true` | Install Outline / Heading Navigator plugin for Joplin desktop. |
| `myFeatures.programs.office.joplin.plugins.richMarkdown` | bool | `true` | Install Rich Markdown plugin for Joplin desktop. |
| `myFeatures.programs.office.languagetool.apiUrl` | `str` | `"http://localhost:8010"` | Self-hosted LanguageTool API backend URL for local text analysis & linting. |
| `myFeatures.programs.office.languagetool.enable` | bool | `false` | Whether to enable LanguageTool Desktop proofreading & style linter application. |
| `myFeatures.programs.office.libreoffice.components.base` | bool | `true` | LibreOffice Base database frontend. |
| `myFeatures.programs.office.libreoffice.components.calc` | bool | `true` | LibreOffice Calc spreadsheet processor. |
| `myFeatures.programs.office.libreoffice.components.draw` | bool | `true` | LibreOffice Draw vector graphics editor. |
| `myFeatures.programs.office.libreoffice.components.impress` | bool | `true` | LibreOffice Impress presentation tool. |
| `myFeatures.programs.office.libreoffice.components.math` | bool | `true` | LibreOffice Math formula editor. |
| `myFeatures.programs.office.libreoffice.components.writer` | bool | `true` | LibreOffice Writer word processor. |
| `myFeatures.programs.office.libreoffice.enable` | bool | `false` | Whether to enable LibreOffice - The premiere open-source office productivity suite. |
| `myFeatures.programs.office.libreoffice.enableJava` | bool | `true` | Enable Java JRE support (required for LibreOffice Base relational database engine). |
| `myFeatures.programs.office.libreoffice.enableLanguageTool` | bool | `true` | Enable LanguageTool grammar checker support. |
| `myFeatures.programs.office.libreoffice.enableOfficeFonts` | bool | `true` | Install office-compatible fonts (Liberation, Carlito, Caladea, FreeFont). |
| `myFeatures.programs.office.libreoffice.iconTheme` | `enum` | `"colibre"` | Icon theme for LibreOffice toolbars. |
| `myFeatures.programs.office.libreoffice.spellcheck` | bool | `true` | Enable Hunspell spellcheckers and dictionaries (en_US, en_GB). |
| `myFeatures.programs.office.libreoffice.variant` | `enum` | `"fresh"` | LibreOffice release branch: 'fresh' (latest features) or 'still' (stable enterprise). |
| `myFeatures.programs.office.lightweight.abiword` | bool | `true` | Enable AbiWord lightweight GTK word processor. |
| `myFeatures.programs.office.lightweight.enable` | bool | `false` | Whether to enable Lightweight modular office tools (AbiWord, Gnumeric, PDFArranger, Evince). |
| `myFeatures.programs.office.lightweight.evince` | bool | `true` | Enable Evince document viewer for PDF and PostScript. |
| `myFeatures.programs.office.lightweight.gnumeric` | bool | `true` | Enable Gnumeric high-speed spreadsheet engine. |
| `myFeatures.programs.office.lightweight.pdfarranger` | bool | `true` | Enable PDFArranger page merger & re-order utility. |
| `myFeatures.programs.office.onlyoffice.defaultFormat` | `enum` | `"ooxml"` | Default document format target (.docx/.xlsx/.pptx vs .odt/.ods/.odp). |
| `myFeatures.programs.office.onlyoffice.enable` | bool | `false` | Whether to enable ONLYOFFICE Desktop Editors. |
| `myFeatures.programs.office.onlyoffice.enablePlugins` | bool | `true` | Enable ONLYOFFICE plugins store (Translator, OCR, HTML, YouTube). |
| `myFeatures.programs.office.onlyoffice.enableSpellcheck` | bool | `true` | Enable ONLYOFFICE spellchecking engine. |
| `myFeatures.programs.office.onlyoffice.uiTheme` | `enum` | `"dark"` | ONLYOFFICE UI theme preset. |
| `myFeatures.programs.office.pandoc.enable` | bool | `false` | Whether to enable Pandoc & TeX Live document publishing engine. |
| `myFeatures.programs.office.pandoc.texlive` | bool | `true` | Whether to include TeX Live system package for PDF generation. |
| `myFeatures.programs.office.softmaker.components.planmaker` | bool | `true` | PlanMaker spreadsheet editor. |
| `myFeatures.programs.office.softmaker.components.presentations` | bool | `true` | Presentations slide deck tool. |
| `myFeatures.programs.office.softmaker.components.textmaker` | bool | `true` | TextMaker word processor. |
| `myFeatures.programs.office.softmaker.enable` | bool | `false` | Whether to enable SoftMaker FreeOffice / Office Suite. |
| `myFeatures.programs.office.softmaker.variant` | `enum` | `"freeoffice"` | SoftMaker package variant: 'freeoffice' (Free edition) or 'office' (Professional edition). |
| `myFeatures.programs.office.trilium.enable` | bool | `false` | Whether to enable Trilium Notes desktop application. |
| `myFeatures.programs.office.trilium.gui` | bool | `true` | Whether to install the Trilium Notes desktop client application. |
| `myFeatures.programs.office.typst.enable` | bool | `false` | Whether to enable Typst modern typesetting engine & PDF compiler. |
| `myFeatures.programs.office.wpsoffice.components.pdf` | bool | `true` | WPS PDF viewer and editor. |
| `myFeatures.programs.office.wpsoffice.components.presentation` | bool | `true` | WPS Presentation slide deck editor. |
| `myFeatures.programs.office.wpsoffice.components.spreadsheets` | bool | `true` | WPS Spreadsheets spreadsheet app. |
| `myFeatures.programs.office.wpsoffice.components.writer` | bool | `true` | WPS Writer word processor. |
| `myFeatures.programs.office.wpsoffice.enable` | bool | `false` | Whether to enable WPS Office Suite. |
| `myFeatures.programs.office.wpsoffice.enableSymbolFonts` | bool | `true` | Install missing WPS Office symbol fonts (Wingdings, Webdings, Symbol). |
| `myFeatures.programs.office.zotero.betterBibtex` | bool | `true` | Enable Better BibTeX plugin support for static citekey generation and auto-export. |
| `myFeatures.programs.office.zotero.connector` | bool | `true` | Enable browser Zotero Connector extension for one-click web source & DOI capture. |
| `myFeatures.programs.office.zotero.defaultPdf` | bool | `false` | Set Zotero as the default application for opening PDF files. |
| `myFeatures.programs.office.zotero.enable` | bool | `false` | Whether to enable Zotero desktop reference manager & PDF assistant. |
| `myFeatures.programs.office.zotero.gui` | bool | `true` | Whether to install the Zotero GUI client application. |

______________________________________________________________________

<a id="platforms-desktops"></a>

## 🪟 Platforms: Window Managers & Compositors

> Granular configuration for 18+ Wayland compositors and X11 window managers.

**Total Options**: 71

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.platforms.desktops.awesome.enable` | bool | `false` | Whether to enable AwesomeWM (Lua-programmable Dynamic X11 Tiling Window Manager). |
| `myFeatures.platforms.desktops.awesome.extraConfig` | `listOf` | `[]` | Extra Lua code appended to rc.lua |
| `myFeatures.platforms.desktops.bspwm.borderWidth` | int | `2` | Window border width in pixels |
| `myFeatures.platforms.desktops.bspwm.enable` | bool | `false` | Whether to enable Bspwm (Binary Space Partitioning X11 Tiling Window Manager). |
| `myFeatures.platforms.desktops.bspwm.extraConfig` | `listOf` | `[]` | Extra shell lines appended to bspwmrc |
| `myFeatures.platforms.desktops.bspwm.windowGap` | int | `8` | Window gap in pixels |
| `myFeatures.platforms.desktops.budgie.enable` | bool | `false` | Whether to enable Budgie Desktop Environment. |
| `myFeatures.platforms.desktops.cinnamon.enable` | bool | `false` | Whether to enable Cinnamon Desktop Environment. |
| `myFeatures.platforms.desktops.cosmic.enable` | bool | `false` | Whether to enable COSMIC Desktop Environment. |
| `myFeatures.platforms.desktops.dwm.enable` | bool | `false` | Whether to enable DWM (Suckless Dynamic X11 Tiling Window Manager). |
| `myFeatures.platforms.desktops.gnome.enable` | bool | `false` | Whether to enable GNOME Desktop Environment. |
| `myFeatures.platforms.desktops.hyprland.animations` | bool | `true` | Enable window and workspace animations |
| `myFeatures.platforms.desktops.hyprland.blur` | bool | `true` | Enable background blur for transparent surfaces |
| `myFeatures.platforms.desktops.hyprland.borderSize` | int | `2` | Window border size in pixels |
| `myFeatures.platforms.desktops.hyprland.enable` | bool | `false` | Whether to enable Hyprland Dynamic Tiling Wayland Compositor. |
| `myFeatures.platforms.desktops.hyprland.extraConfig` | `listOf` | `[]` | Extra raw configuration lines appended to hyprland.conf |
| `myFeatures.platforms.desktops.hyprland.gapsIn` | int | `4` | Inner gaps between windows in pixels |
| `myFeatures.platforms.desktops.hyprland.gapsOut` | int | `8` | Outer gaps between windows and monitor edges in pixels |
| `myFeatures.platforms.desktops.hyprland.modKey` | `enum` | `"SUPER"` | Primary modifier key for Hyprland bindings |
| `myFeatures.platforms.desktops.hyprland.monitors` | `listOf` | `[]` | Declarative list of display monitors for Hyprland |
| `myFeatures.platforms.desktops.hyprland.rounding` | int | `10` | Corner rounding radius in pixels |
| `myFeatures.platforms.desktops.hyprland.shadow` | bool | `true` | Enable window drop shadows |
| `myFeatures.platforms.desktops.i3.borderWidth` | int | `2` | Window border width in pixels |
| `myFeatures.platforms.desktops.i3.enable` | bool | `false` | Whether to enable i3 X11 Tiling Window Manager. |
| `myFeatures.platforms.desktops.i3.extraConfig` | `listOf` | `[]` | Extra raw configuration lines appended to i3 config |
| `myFeatures.platforms.desktops.i3.gapsInner` | int | `4` | Inner window gaps in pixels |
| `myFeatures.platforms.desktops.i3.gapsOuter` | int | `8` | Outer window gaps in pixels |
| `myFeatures.platforms.desktops.i3.modKey` | `enum` | `"Mod4"` | Primary modifier key for i3 (Mod4 = Super, Mod1 = Alt) |
| `myFeatures.platforms.desktops.kde.enable` | bool | `false` | Whether to enable KDE Plasma 6 Desktop. |
| `myFeatures.platforms.desktops.kde.karousel.enable` | bool | `false` | Whether to enable Karousel scrollable-tiling KWin script. |
| `myFeatures.platforms.desktops.kde.wallpaper.stylix` | bool | `true` | Set KDE Plasma desktop wallpaper to match Stylix theme image |
| `myFeatures.platforms.desktops.labwc.enable` | bool | `false` | Whether to enable Labwc (Openbox-inspired Stacking Wayland Compositor). |
| `myFeatures.platforms.desktops.labwc.extraConfig` | `listOf` | `[]` | Extra XML configuration lines for labwc rc.xml |
| `myFeatures.platforms.desktops.lxqt.enable` | bool | `false` | Whether to enable LXQt Lightweight Qt Desktop Environment. |
| `myFeatures.platforms.desktops.mangowc.borderWidth` | int | `2` | Window border width in pixels |
| `myFeatures.platforms.desktops.mangowc.enable` | bool | `false` | Whether to enable MangoWC / MangoWM (SceneFX-accelerated Wayland Compositor). |
| `myFeatures.platforms.desktops.mangowc.extraConfig` | `listOf` | `[]` | Extra configuration lines appended to ~/.config/mango/config.conf |
| `myFeatures.platforms.desktops.mangowc.gaps` | int | `8` | Window gaps in pixels |
| `myFeatures.platforms.desktops.mangowc.modKey` | `enum` | `"SUPER"` | Primary modifier key for MangoWC bindings |
| `myFeatures.platforms.desktops.mate.enable` | bool | `false` | Whether to enable MATE Desktop Environment. |
| `myFeatures.platforms.desktops.niri.defaultColumnWidth` | `nullOr` | `null` | Default column width proportion for Niri layout (e.g. 1.0 for 100%, 0.5 for 50%) |
| `myFeatures.platforms.desktops.niri.enable` | bool | `false` | Whether to enable Niri Window Manager. |
| `myFeatures.platforms.desktops.niri.extraConfig` | `listOf` | `[]` | Extra Niri configuration in KDL format |
| `myFeatures.platforms.desktops.niri.gaps` | int | `8` | Gaps around windows in logical pixels |
| `myFeatures.platforms.desktops.niri.modKey` | `enum` | `"left-alt"` | Modifier key for Niri bindings |
| `myFeatures.platforms.desktops.niri.monitors` | `listOf` | `[]` | List of monitors configured for Niri. Supports presets (e.g. '1080p', '1440p', '4k', 'ultrawide-1440p'), orientations ('horizontal', 'vertical'), VRR, refresh rates, positions, and scaling. |
| `myFeatures.platforms.desktops.niri.presetColumnWidths` | `listOf` | `[0.33333,0.5,0.66667,1.0]` | Preset column widths proportions for cycling with switch-preset-column-width |
| `myFeatures.platforms.desktops.niri.setXwaylandPrimary` | bool | `true` | Whether to automatically set the designated primary monitor in Xwayland at startup. |
| `myFeatures.platforms.desktops.niri.settings` | `attrsOf` | `{}` | Niri settings |
| `myFeatures.platforms.desktops.openbox.enable` | bool | `false` | Whether to enable Openbox (Classic Lightweight X11 Stacking Window Manager). |
| `myFeatures.platforms.desktops.qtile.backend` | `enum` | `"wayland"` | Display backend for Qtile (wayland or x11) |
| `myFeatures.platforms.desktops.qtile.enable` | bool | `false` | Whether to enable Qtile (Python-based Dynamic Tiling Window Manager). |
| `myFeatures.platforms.desktops.qtile.extraConfig` | `listOf` | `[]` | Extra Python code appended to config.py |
| `myFeatures.platforms.desktops.river.borderWidth` | int | `2` | Border width in pixels |
| `myFeatures.platforms.desktops.river.enable` | bool | `false` | Whether to enable River Dynamic Tiling Wayland Compositor. |
| `myFeatures.platforms.desktops.river.extraConfig` | `listOf` | `[]` | Extra shell commands executed in river init script |
| `myFeatures.platforms.desktops.river.modKey` | `enum` | `"Super"` | Primary modifier key for River bindings |
| `myFeatures.platforms.desktops.sway.borderWidth` | int | `2` | Window border width in pixels |
| `myFeatures.platforms.desktops.sway.enable` | bool | `false` | Whether to enable Sway i3-compatible Wayland Tiling Window Manager. |
| `myFeatures.platforms.desktops.sway.extraConfig` | `listOf` | `[]` | Extra raw configuration lines appended to sway config |
| `myFeatures.platforms.desktops.sway.gapsInner` | int | `4` | Inner window gaps in pixels |
| `myFeatures.platforms.desktops.sway.gapsOuter` | int | `8` | Outer window gaps in pixels |
| `myFeatures.platforms.desktops.sway.modKey` | `enum` | `"Mod4"` | Primary modifier key for Sway (Mod4 = Super, Mod1 = Alt) |
| `myFeatures.platforms.desktops.sway.monitors` | `listOf` | `[]` | Declarative list of display monitors for Sway |
| `myFeatures.platforms.desktops.wayfire.enable` | bool | `false` | Whether to enable Wayfire 3D Compiz-style Wayland Compositor. |
| `myFeatures.platforms.desktops.wayfire.extraConfig` | `listOf` | `[]` | Extra configuration lines for wayfire.ini |
| `myFeatures.platforms.desktops.wayfire.plugins` | `listOf` | `["/nix/store/db36q5v7pfibrvfqm9vc0s1k...` | List of Wayfire plugins to install |
| `myFeatures.platforms.desktops.xfce.enable` | bool | `false` | Whether to enable XFCE Desktop Environment. |
| `myFeatures.platforms.desktops.xmonad.configGhc` | `listOf` | `[]` | Extra Haskell configuration lines |
| `myFeatures.platforms.desktops.xmonad.enable` | bool | `false` | Whether to enable XMonad (Haskell-extensible Dynamic X11 Tiling Window Manager). |
| `myFeatures.platforms.desktops.xmonad.enableContribAndExtras` | bool | `true` | Enable xmonad-contrib and xmonad-extras libraries |

______________________________________________________________________

<a id="platforms-addons"></a>

## 📊 Platforms: Desktop Addons & Panels

> Status bars, notification daemons, on-screen displays, display managers, app launchers, and lockscreens.

**Total Options**: 15

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.platforms.addons.displayManager.extraConfig` | `listOf` | `[]` | Extra compositor configuration lines for Wayland-based display managers (e.g. Sway for ReGreet). |
| `myFeatures.platforms.addons.displayManager.manager` | `enum` | `"none"` | Configure myFeatures.platforms.addons.displayManager.manager. |
| `myFeatures.platforms.addons.displayManager.primaryOutput` | `nullOr` | `null` | Explicit primary monitor output for the display manager (e.g. 'DP-1'). If null, falls back to the desktop's primary monitor. |
| `myFeatures.platforms.addons.displayManager.syncOutputs` | bool | `true` | Whether to synchronize monitor resolutions, positions, rotations, and primary focus from the desktop compositor configuration into the display manager. |
| `myFeatures.platforms.addons.fuzzel.enable` | bool | `false` | Whether to enable Fuzzel according to stylix. |
| `myFeatures.platforms.addons.idle.enable` | bool | `false` | Whether to enable Swayidle/lock service. |
| `myFeatures.platforms.addons.ironbar.enable` | bool | `false` | Whether to enable Ironbar status bar. |
| `myFeatures.platforms.addons.noctalia-shell.enable` | bool | `false` | Whether to enable Noctalia Shell (Wayland Shell). |
| `myFeatures.platforms.addons.noctalia-v5.enable` | bool | `false` | Whether to enable Noctalia Shell v5 (Wayland Shell). |
| `myFeatures.platforms.addons.swaybg.enable` | bool | `false` | Whether to enable swaybg service. |
| `myFeatures.platforms.addons.swaylock.enable` | bool | `false` | Whether to enable swaylock screen locker. |
| `myFeatures.platforms.addons.swaync.enable` | bool | `false` | Whether to enable Sway Notification Center. |
| `myFeatures.platforms.addons.swayosd.enable` | bool | `false` | Whether to enable SwayOSD. |
| `myFeatures.platforms.addons.swww.enable` | bool | `false` | Whether to enable swww wallpaper daemon. |
| `myFeatures.platforms.addons.waybar.enable` | bool | `false` | Whether to enable waybar status bar. |

______________________________________________________________________

<a id="platforms-styling"></a>

## 🎨 Platforms: Styling & Themes

> Stylix universal theme engine, curated wallpaper flavors, and desktop keybinding layers.

**Total Options**: 17

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.platforms.styling.flavors.forest.enable` | bool | `false` | Whether to enable Apollo's Forest Flavor (Universal across compositors & shells). |
| `myFeatures.platforms.styling.flavors.gruvbox.enable` | bool | `false` | Whether to enable Apollo's Gruvbox Flavor (Universal across compositors & shells). |
| `myFeatures.platforms.styling.flavors.sky.enable` | bool | `false` | Whether to enable Apollo's Sky Flavor (Universal across compositors & shells). |
| `myFeatures.platforms.styling.flavors.space.enable` | bool | `false` | Whether to enable Apollo's Space Flavor (Universal across compositors & shells). |
| `myFeatures.platforms.styling.flavors.strawberry.enable` | bool | `false` | Whether to enable Apollo's Strawberry Flavor (Universal across compositors & shells). |
| `myFeatures.platforms.styling.gruvboxNoctalia.enable` | bool | `false` | Whether to enable Apollo's Gruvbox Noctalia Rice. |
| `myFeatures.platforms.styling.niriKeybinds.enable` | bool | `false` | Whether to enable Apollo's Niri Keybinds. |
| `myFeatures.platforms.styling.skyNoctalia.enable` | bool | `false` | Whether to enable Apollo's Sky Noctalia v5 Rice. |
| `myFeatures.platforms.styling.stylix.enable` | bool | `false` | Whether to enable Stylix Framework. |
| `myFeatures.platforms.styling.stylix.polarity` | `enum` | `"dark"` | Theme polarity (dark or light). |
| `myFeatures.platforms.styling.stylix.scheme` | `nullOr` | `null` | Path to the base16 scheme file or an attribute set. If null, Stylix generates colors from the wallpaper. |
| `myFeatures.platforms.styling.stylix.wallpaper` | `path` | *none* | Path to the wallpaper image. |
| `myFeatures.platforms.styling.themes.forest.enable` | bool | `false` | Whether to enable Forest Theme. |
| `myFeatures.platforms.styling.themes.gruvbox.enable` | bool | `false` | Whether to enable Gruvbox Theme. |
| `myFeatures.platforms.styling.themes.sky.enable` | bool | `false` | Whether to enable Sky Theme. |
| `myFeatures.platforms.styling.themes.space.enable` | bool | `false` | Whether to enable Space Theme Stylix Settings. |
| `myFeatures.platforms.styling.themes.strawberry.enable` | bool | `false` | Whether to enable Strawberry Theme. |

______________________________________________________________________

<a id="core-boot"></a>

## 🚀 Core: Bootloader & Kernel

> Limine, Systemd-Boot, GRUB, SecureBoot (Lanzaboote), kernel selection, and console resolutions.

**Total Options**: 8

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.core.boot.boot.enable` | bool | `false` | Whether to enable Common Bootloader configuration. |
| `myFeatures.core.boot.enable` | bool | `false` | Whether to enable Bootloader Selection Branch. |
| `myFeatures.core.boot.kernel` | `enum` | `"default"` | The kernel package to use. |
| `myFeatures.core.boot.loader` | `enum` | `"limine"` | The bootloader to use. |
| `myFeatures.core.boot.plymouth.enable` | bool | `true` | Whether to enable Plymouth graphical boot splash. |
| `myFeatures.core.boot.resolution` | `nullOr` | `null` | Framebuffer / GOP display resolution for the bootloader (e.g. '2560x1440', '1920x1080'). If null, bootloader chooses default. |
| `myFeatures.core.boot.secureBoot.enable` | bool | `false` | Whether to enable Native Bootloader Secure Boot. |
| `myFeatures.core.boot.timeout` | int | `1` | Bootloader menu timeout in seconds. |

______________________________________________________________________

<a id="core-security"></a>

## 🔒 Core: Security & Secrets

> Agenix asymmetric secret management, AppArmor MAC profiles, and OpenSSH configuration.

**Total Options**: 6

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.core.security.agenix.enable` | bool | `false` | agenix-rekey for secret management |
| `myFeatures.core.security.agenix.usePrivateSecrets` | bool | `true` | Whether to look for secrets inside the private solar-secrets repository input. |
| `myFeatures.core.security.security.enable` | bool | `false` | Whether to enable General System Security Hardening. |
| `myFeatures.core.security.security.useAppArmor` | bool | `false` | Whether to enable AppArmor MAC support. |
| `myFeatures.core.security.security.useOOMD` | bool | `false` | Whether to enable Systemd-OOMD stability. |
| `myFeatures.core.security.ssh.enable` | bool | `false` | Whether to enable SSH Service. |

______________________________________________________________________

<a id="core-system"></a>

## 💾 Core: System, Disko & Users

> Declarative disk partitioning (Disko), ephemeral root preservation, user management, and virtualization.

**Total Options**: 21

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.core.system.core-branch.enable` | bool | `false` | Whether to enable Core System Foundation. |
| `myFeatures.core.system.core-branch.usePersistence` | bool | `false` | Enable Wipe-on-Boot Preservation for this host. |
| `myFeatures.core.system.core-branch.virtualization.docker` | bool | `false` | Whether to enable Docker Engine. |
| `myFeatures.core.system.core-branch.virtualization.libvirt` | bool | `false` | Whether to enable Virt-Manager/VMs. |
| `myFeatures.core.system.disko.bulkDisks` | `listOf` | `[]` | List of slow disks (HDD) for the bulk storage pool. |
| `myFeatures.core.system.disko.enable` | bool | `false` | Whether to enable Universal Hardware-Aware Disko. |
| `myFeatures.core.system.disko.enableLuks` | bool | `true` | Enable LUKS encryption on disko partitions. |
| `myFeatures.core.system.disko.speedDisks` | `listOf` | `["/dev/nvme0n1"]` | List of fast disks (NVMe/SSD) for the primary speed pool. |
| `myFeatures.core.system.fonts.enable` | bool | `false` | Whether to enable Core System Fonts. |
| `myFeatures.core.system.localeChicago.enable` | bool | `false` | Whether to enable Chicago Locale/Timezone. |
| `myFeatures.core.system.preservation.coldPath` | `str` | `"/persist"` | The path for cold storage/archives (HDD). Falls back to persistentPath if no HDDs. |
| `myFeatures.core.system.preservation.enable` | bool | `false` | Whether to enable Wipe-on-Boot Preservation. |
| `myFeatures.core.system.preservation.persistentPath` | `str` | `"/persist"` | The root path for persistent storage (Speed/NVMe). |
| `myFeatures.core.system.users.agenixPassword` | bool | `false` | Whether to enable agenix-managed passwords for users. |
| `myFeatures.core.system.users.enable` | bool | `false` | Whether to enable User Management. |
| `myFeatures.core.system.users.mainHome` | `path` | `"/home/daphne"` | The home directory of the primary user. |
| `myFeatures.core.system.users.mainUser` | `str` | `"daphne"` | The primary user of the system. |
| `myFeatures.core.system.users.usernames` | `listOf` | `["apollo"]` | List of users to configure. |
| `myFeatures.core.system.virtualization.docker` | bool | `false` | Whether to enable Docker Engine. |
| `myFeatures.core.system.virtualization.enable` | bool | `false` | Whether to enable Virtualization Suite. |
| `myFeatures.core.system.virtualization.libvirt` | bool | `false` | Whether to enable Libvirt/Virt-Manager. |

______________________________________________________________________

<a id="core-shell"></a>

## 🐚 Core: Shell & CLI

> Zsh, Starship prompt, core CLI utility packages, and modern terminal environments.

**Total Options**: 5

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.core.shell.cli.enable` | bool | `false` | Whether to enable Core CLI Utilities. |
| `myFeatures.core.shell.shell-branch.aliases` | bool | `false` | Whether to enable Custom System Aliases. |
| `myFeatures.core.shell.shell-branch.enable` | bool | `false` | Whether to enable Interactive Shell Environment. |
| `myFeatures.core.shell.shell-branch.p10k` | bool | `false` | Whether to enable Powerlevel10k Theme. |
| `myFeatures.core.shell.shell.enable` | bool | `false` | Whether to enable Apollo's Zsh & Starship Setup. |

______________________________________________________________________

<a id="core-nix"></a>

## ❄️ Core: Nix Engine & Channels

> Lix engine implementation, channel tracking, and automated store garbage collection.

**Total Options**: 9

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.core.nix.automation.enable` | bool | `false` | Whether to enable automated GitHub-based flake updates. |
| `myFeatures.core.nix.automation.syncHelper` | bool | `false` | Whether to enable local helper script to sync GitHub updates. |
| `myFeatures.core.nix.cachix.enable` | bool | `false` | Whether to enable Cachix binary caches. |
| `myFeatures.core.nix.channels.currentVersion` | `str` | `"26.11"` | Configure myFeatures.core.nix.channels.currentVersion. |
| `myFeatures.core.nix.channels.isStable` | bool | `false` | Internal: Whether the host is using the stable branch. |
| `myFeatures.core.nix.channels.stableVersion` | `str` | `"26.05"` | Configure myFeatures.core.nix.channels.stableVersion. |
| `myFeatures.core.nix.channels.unstableVersion` | `str` | `"26.11"` | Configure myFeatures.core.nix.channels.unstableVersion. |
| `myFeatures.core.nix.lix.enable` | bool | `true` | Enables Lix in systems |
| `myFeatures.core.nix.nix-settings.enable` | bool | `false` | Whether to enable Core Nix flake and optimization settings. |

______________________________________________________________________

<a id="hardware-cpu-gpu"></a>

## ⚡ Hardware: CPU & GPU Drivers

> AMD, NVIDIA (open/proprietary), Intel, and PRIME hybrid GPU graphics offloading.

**Total Options**: 10

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.hardware.cpu-gpu.amd.enable` | bool | `false` | Enable AMD CPU Support (P-State/Microcode) |
| `myFeatures.hardware.cpu-gpu.amd.gpu` | bool | `false` | Enable AMD GPU Support (amdgpu drivers) |
| `myFeatures.hardware.cpu-gpu.intel.enable` | bool | `false` | Whether to enable Intel Graphics Support. |
| `myFeatures.hardware.cpu-gpu.nvidia.beta` | bool | `false` | Whether to enable Use Nvidia Beta Driver Channel. |
| `myFeatures.hardware.cpu-gpu.nvidia.enable` | bool | `false` | Whether to enable Nvidia Proprietary Drivers. |
| `myFeatures.hardware.cpu-gpu.nvidia.legacy` | bool | `false` | Whether to enable Use Legacy Driver Branch (for P2000/Pascal). |
| `myFeatures.hardware.cpu-gpu.nvidia.open` | bool | `false` | Whether to enable Use Open Source Kernel Modules (Modern). |
| `myFeatures.hardware.cpu-gpu.nvidia.prime.enable` | bool | `false` | Whether to enable Nvidia PRIME Offload Mode (Laptop). |
| `myFeatures.hardware.cpu-gpu.nvidia.prime.intelBusId` | `str` | `"PCI:0:2:0"` | Configure myFeatures.hardware.cpu-gpu.nvidia.prime.intelBusId. |
| `myFeatures.hardware.cpu-gpu.nvidia.prime.nvidiaBusId` | `str` | `"PCI:1:0:0"` | Configure myFeatures.hardware.cpu-gpu.nvidia.prime.nvidiaBusId. |

______________________________________________________________________

<a id="hardware-input"></a>

## 🎮 Hardware: Input & Controllers

> Xbox One/Series, Nintendo Pro, PlayStation DualSense controllers, Wooting analog keyboards, and trackpads.

**Total Options**: 7

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.hardware.input.controllers.enable` | bool | `false` | Whether to enable Game Controller Support. |
| `myFeatures.hardware.input.controllers.nintendo` | bool | `false` | Enable Nintendo Switch (Joy-Con/Pro Controller) support. |
| `myFeatures.hardware.input.controllers.playstation` | bool | `false` | Enable PlayStation (DualShock/DualSense) support. |
| `myFeatures.hardware.input.controllers.xbox` | bool | `false` | Enable Xbox (One/Series/360) controller drivers. |
| `myFeatures.hardware.input.fingerprint.enable` | bool | `false` | Whether to enable Fingerprint Sensor Support. |
| `myFeatures.hardware.input.trackpad.enable` | bool | `false` | Whether to enable Trackpad Settings. |
| `myFeatures.hardware.input.wooting.enable` | bool | `false` | Whether to enable Wooting Keyboard Support. |

______________________________________________________________________

<a id="hardware-peripherals"></a>

## 🔋 Hardware: Peripherals & Mobile

> Battery conservation thresholds, TLP daemon, Bluetooth, and WiFi state management.

**Total Options**: 8

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.hardware.peripherals.battery.aggressive` | bool | `false` | Enable experimental kernel tweaks for maximum savings. |
| `myFeatures.hardware.peripherals.battery.bluetooth.enable` | bool | `false` | Manage Bluetooth power states based on AC/Battery. |
| `myFeatures.hardware.peripherals.battery.enable` | bool | `false` | Whether to enable ThinkPad Power Management. |
| `myFeatures.hardware.peripherals.battery.fullCharge` | bool | `false` | If false, caps charge at 80% to preserve battery health. |
| `myFeatures.hardware.peripherals.bluetooth.enable` | bool | `false` | Whether to enable Enables bluetooth services. |
| `myFeatures.hardware.peripherals.bluetooth.gaming.enable` | bool | `false` | Whether to enable Force low-latency Bluetooth connection parameters for gaming. |
| `myFeatures.hardware.peripherals.wifi.enable` | bool | `false` | Whether to enable Enables Wifi Services. |
| `myFeatures.hardware.peripherals.wifi.persistence` | bool | `true` | Whether to persist WiFi network connections across reboots. |

______________________________________________________________________

<a id="hardware-system"></a>

## 🖥️ Hardware: System Peripherals

> TTY console framebuffer resolutions and OpenRGB lighting controller.

**Total Options**: 4

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.hardware.system.dualboot.enable` | bool | `false` | Whether to enable Enables Windows Dualboot on Mars. |
| `myFeatures.hardware.system.graphics.enable` | bool | `false` | Whether to enable Universal Graphics Acceleration. |
| `myFeatures.hardware.system.ttyResolution.enable` | bool | `false` | Whether to enable TTY Resolution configuration. |
| `myFeatures.hardware.system.ttyResolution.resolution` | `str` | `"2560x1440"` | The resolution to set for the TTY (e.g., 2560x1440) |

______________________________________________________________________

<a id="services-hardware"></a>

## 🖨️ Services: Hardware & Storage

> CUPS printing subsystem and Udisks2 storage auto-mounting daemon.

**Total Options**: 4

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.services.hardware.firmware.enable` | bool | `false` | Whether to enable Enable Firmware Updates. |
| `myFeatures.services.hardware.openrgb.enable` | bool | `false` | Whether to enable OpenRGB. |
| `myFeatures.services.hardware.printing.enable` | bool | `false` | Whether to enable CUPS Printing Support. |
| `myFeatures.services.hardware.udisks2.enable` | bool | `false` | Whether to enable Udisks2 and GVFS for automounting. |

______________________________________________________________________

<a id="services-multimedia"></a>

## 🔊 Services: Multimedia & Audio

> PipeWire low-latency audio stack and Sunshine game/display streaming server.

**Total Options**: 4

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.services.multimedia.audio.enable` | bool | `false` | Whether to enable Pipewire Audio & CLI Utilities. |
| `myFeatures.services.multimedia.moonlight.enable` | bool | `false` | Whether to enable Moonlight: High-performance game streaming client. |
| `myFeatures.services.multimedia.sunshine.enable` | bool | `false` | Whether to enable Sunshine: Open-source GameStream host. |
| `myFeatures.services.multimedia.sunshine.port` | `unsignedInt16` | `47990` | The port for the Sunshine Web UI |

______________________________________________________________________

<a id="services-networking"></a>

## 🌐 Services: Networking & DNS

> Tailscale mesh VPN and Systemd-Resolved DNS resolution daemon.

**Total Options**: 11

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.services.networking.cloudflare.credentialsFile` | `str` | `"/var/lib/cloudflare/tunnel-creds.json"` | Local path to the tunnel JSON credentials |
| `myFeatures.services.networking.cloudflare.domains` | `attrsOf` | `{}` | Configure myFeatures.services.networking.cloudflare.domains. |
| `myFeatures.services.networking.cloudflare.enable` | bool | `false` | Whether to enable Cloudflare Tunnel. |
| `myFeatures.services.networking.cloudflare.tunnelId` | `str` | *none* | The UUID of your Cloudflare tunnel |
| `myFeatures.services.networking.ddns.domains` | `listOf` | `[]` | List of apollan.cc subdomains to update |
| `myFeatures.services.networking.ddns.enable` | bool | `false` | Whether to enable Cloudflare DDNS. |
| `myFeatures.services.networking.enable` | bool | `false` | Whether to enable Core Networking Suite. |
| `myFeatures.services.networking.resolved.enable` | bool | `false` | Whether to enable systemd-resolved network name resolution manager. |
| `myFeatures.services.networking.syncthing.enable` | bool | `false` | Whether to enable Syncthing. |
| `myFeatures.services.networking.tailscale.enable` | bool | `false` | Whether to enable Tailscale VPN. |
| `myFeatures.services.networking.wifi.enable` | bool | `false` | Whether to enable Declarative WiFi via NetworkManager. |

______________________________________________________________________

<a id="services-system"></a>

## 📦 Services: System Daemons

> Flatpak universal application runtime and XDG Desktop Portals.

**Total Options**: 10

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.services.system.flatpak.enable` | bool | `false` | Whether to enable Flatpak Support. |
| `myFeatures.services.system.flatpak.mcpelauncher.enable` | bool | `false` | Whether to enable MCPELauncher (Minecraft Bedrock Edition) via Flatpak. |
| `myFeatures.services.system.flatpak.overrides` | `attrs` | `{}` | Flatpak overrides to configure via nix-flatpak. |
| `myFeatures.services.system.flatpak.packages` | `listOf` | `[]` | Declarative Flatpak packages to install via nix-flatpak. |
| `myFeatures.services.system.flatpak.remotes` | `listOf` | `[]` | Additional Flatpak remotes to configure via nix-flatpak. |
| `myFeatures.services.system.flatpak.sober.enable` | bool | `false` | Whether to enable Sober (Roblox) via Flatpak. |
| `myFeatures.services.system.flatpak.update.auto.enable` | bool | `false` | Enable periodic automatic Flatpak updates via systemd timer. |
| `myFeatures.services.system.flatpak.update.auto.onCalendar` | string | `"weekly"` | Frequency of periodic Flatpak updates. |
| `myFeatures.services.system.flatpak.update.onActivation` | bool | `false` | Whether to upgrade Flatpak applications during system activation. |
| `myFeatures.services.system.xdgPortals.enable` | bool | `false` | Whether to enable XDG Portals for Wayland/Desktop. |

______________________________________________________________________

<a id="services-servers"></a>

## 🖧 Services: Server Stack & Self-Hosted

> Server daemons including Nginx, Minecraft (No Man's Land, Create Aero, SLLV), Prometheus, Grafana, Nextcloud, Forgejo, Vaultwarden, and MinIO.

**Total Options**: 40

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.services.nginx.domain` | `nullOr` | `null` | Default domain for Nginx (optional). |
| `myFeatures.services.nginx.enable` | bool | `false` | Whether to enable Nginx Reverse Proxy. |
| `myFeatures.services.servers.factorio.enable` | bool | `false` | Whether to enable Factorio Headless Server. |
| `myFeatures.services.servers.factorio.port` | `unsignedInt16` | `34197` | UDP port for the Factorio server |
| `myFeatures.services.servers.joplin.baseUrl` | `str` | `"https://joplin.apollan.cc"` | Public base URL of Joplin Server. |
| `myFeatures.services.servers.joplin.enable` | bool | `false` | Whether to enable Joplin Synchronization Server (Solar Managed). |
| `myFeatures.services.servers.joplin.port` | `unsignedInt16` | `22300` | Listening port for Joplin Server. |
| `myFeatures.services.servers.languagetool.allowOrigin` | `str` | `"*"` | Allowed origin header value for CORS access. |
| `myFeatures.services.servers.languagetool.baseUrl` | `str` | `"https://languagetool.apollan.cc"` | Public base URL of self-hosted LanguageTool server. |
| `myFeatures.services.servers.languagetool.enable` | bool | `false` | Whether to enable LanguageTool Self-Hosted Proofreading API Server. |
| `myFeatures.services.servers.languagetool.port` | `unsignedInt16` | `8010` | Listening port for LanguageTool HTTP API server. |
| `myFeatures.services.servers.minecraft.admin.enable` | bool | `false` | Whether to enable Minecraft Admin User and Directory Configuration. |
| `myFeatures.services.servers.minecraft.create-aero.enable` | bool | `false` | Whether to enable Create Aeronautics Minecraft 1.21.1 Neoforge Modpack. |
| `myFeatures.services.servers.minecraft.create-aero.mapPort` | `unsignedInt16` | `8100` | The port for the BlueMap web interface. |
| `myFeatures.services.servers.minecraft.create-aero.port` | `unsignedInt16` | `25565` | Configure myFeatures.services.servers.minecraft.create-aero.port. |
| `myFeatures.services.servers.minecraft.no-mans-land.autoBackup` | bool | `true` | Enable automated BorgBackup snapshots for the server world data. |
| `myFeatures.services.servers.minecraft.no-mans-land.enable` | bool | `false` | Whether to enable PhasMC No Man's Land Minecraft 1.21.1 NeoForge Modpack Server. |
| `myFeatures.services.servers.minecraft.no-mans-land.jvmOpts` | `str` | `"-Xmx12G -Xms12G -XX:+UseZGC -XX:+ZGenerational -XX:+UnlockExperimentalVMOptions -Dneoforge.forceignoreConfigMismatch=true -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:+PerfDisableSharedMem"` | JVM execution flags and memory allocation. |
| `myFeatures.services.servers.minecraft.no-mans-land.motd` | `str` | `"PhasMC No Man's Land 1.21.1"` | Message of the day displayed in the server list. |
| `myFeatures.services.servers.minecraft.no-mans-land.port` | `unsignedInt16` | `25565` | The port for the Minecraft server. |
| `myFeatures.services.servers.minecraft.no-mans-land.voicePort` | `unsignedInt16` | `24454` | The UDP port for Simple Voice Chat communication. |
| `myFeatures.services.servers.minecraft.sllv.enable` | bool | `false` | Whether to enable Minecraft MCA Fabric Server (1.21.1). |
| `myFeatures.services.servers.minecraft.sllv.port` | `unsignedInt16` | `25565` | Configure myFeatures.services.servers.minecraft.sllv.port. |
| `myFeatures.services.servers.terraria.enable` | bool | `false` | Whether to enable Terraria Dedicated Server (Solar Managed). |
| `myFeatures.services.servers.terraria.maxPlayers` | int | `8` | Configure myFeatures.services.servers.terraria.maxPlayers. |
| `myFeatures.services.servers.terraria.openFirewall` | bool | `true` | Configure myFeatures.services.servers.terraria.openFirewall. |
| `myFeatures.services.servers.terraria.password` | `str` | `""` | Configure myFeatures.services.servers.terraria.password. |
| `myFeatures.services.servers.terraria.port` | `unsignedInt16` | `7777` | Configure myFeatures.services.servers.terraria.port. |
| `myFeatures.services.servers.terraria.worldSize` | `enum` | `"large"` | Configure myFeatures.services.servers.terraria.worldSize. |
| `myFeatures.services.servers.trilium.enable` | bool | `false` | Whether to enable Trilium Server (Solar Managed). |
| `myFeatures.services.servers.trilium.port` | `unsignedInt16` | `8080` | Port for the Trilium server |
| `myFeatures.services.servers.zotero.baseUrl` | `str` | `"https://zotero.apollan.cc"` | Public base URL of Zotero WebDAV host. |
| `myFeatures.services.servers.zotero.configFile` | `nullOr` | `null` | Path to custom WebDAV config YAML file on server disk. Overrides declarative settings if set, allowing runtime user/password management outside Nix. |
| `myFeatures.services.servers.zotero.dataDir` | `str` | `"/var/lib/zotero-webdav"` | Storage path for Zotero WebDAV attachment files. |
| `myFeatures.services.servers.zotero.enable` | bool | `false` | Whether to enable Zotero WebDAV Attachment Server (Solar Managed). |
| `myFeatures.services.servers.zotero.nginx.enable` | bool | `true` | Enable Nginx virtualHost proxy for Zotero WebDAV host. |
| `myFeatures.services.servers.zotero.password` | `str` | `"zotero"` | WebDAV authentication password or bcrypt hash for Zotero client attachment sync. |
| `myFeatures.services.servers.zotero.passwordHash` | `nullOr` | `null` | Optional pre-hashed bcrypt string for WebDAV authentication ($2a$...). |
| `myFeatures.services.servers.zotero.port` | `unsignedInt16` | `8081` | Listening port for Zotero WebDAV server. |
| `myFeatures.services.servers.zotero.username` | `str` | `"zotero"` | WebDAV authentication username for Zotero client attachment sync. |

______________________________________________________________________

<a id="darwin-system"></a>

## 🍎 Darwin (macOS) Specifics

> macOS host core system configurations and declarative Homebrew integration.

**Total Options**: 2

| Option Path | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `myFeatures.darwin.system.core.enable` | bool | `false` | Whether to enable Core macOS System Settings. |
| `myFeatures.darwin.system.homebrew.enable` | bool | `false` | Whether to enable Enable Homebrew. |

______________________________________________________________________
