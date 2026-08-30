# Desktop Environments & Compositors 🖥️

Solar provides declarative, composable support for multiple modern Wayland desktop environments and scrollable compositors.

______________________________________________________________________

## 🌊 1. Niri (Scrollable Tiling Compositor)

**Niri** is the flagship desktop compositor for Solar workstations (**Mars** and **Mercury**). It features an infinite horizontal ribbon layout where windows are tiled onto scrollable columns.

### Key Features in Solar:

- **Declarative Monitor Resolution & Layout Engine**:
  Configured via `myFeatures.platforms.desktops.niri.monitors`:
  ```nix
  myFeatures.platforms.desktops.niri.monitors = [
    {
      name = "ASUSTek COMPUTER INC VG27WQ3B TALMTR031961";
      aliases = [ "DP-2" "DP-4" ];
      resolution = "1440p";       # Presets: "1080p", "1440p", "4k", "720p", "ultrawide-1440p"
      refresh = 180.0;            # 180Hz refresh rate
      orientation = "horizontal"; # "horizontal", "vertical", "vertical-inverted", "inverted"
      position = { x = 1080; y = 0; };
      vrr = true;                 # Adaptive Sync / FreeSync / G-Sync
      primary = true;
      focusAtStartup = true;
    }
  ];
  ```
- **Unified Keybindings**: Consistent window management, workspace navigation, application spawning, and media controls across all active themes.
- **Micro-Compositor Integration**: Native coordination with Gamescope for smooth game transitions.

______________________________________________________________________

## 🎨 2. KDE Plasma 6

**KDE Plasma 6** is the primary desktop environment for gaming rigs (**Elara** and **Europa**) and handhelds (**Amalthea**).

- **Wayland Native**: Running pure Wayland session with fractional scaling, HDR, and per-monitor color management.
- **Stylix Integration**: Automatic synchronization of color palettes, widget styles, icon sets, and SDDM greeters.
- **Gaming First**: Full support for Steam Big Picture, MangoHud overlays, and GameMode scheduler boosts.

______________________________________________________________________

## 🪟 3. GNOME

Solar includes a modern, streamlined **GNOME** desktop module with native GDM display manager integration, Wayland session support, and Stylix styling.

______________________________________________________________________

## 🚀 4. COSMIC Desktop Environment

The next-generation Rust-based desktop environment by System76, featured on the testbed machine **Io**:

- Powered by `cosmic-comp`, `cosmic-panel`, and `cosmic-applets`.
- Native **COSMIC Greeter** integration.
- Stylix color palette theming across all native iced GUI widgets.

______________________________________________________________________

## ✨ 5. Hyprland (Dynamic Tiling Wayland Compositor)

**Hyprland** brings modern dynamic tiling, fluid animations, background blur, and customizable decorations:

- Declarative monitor list with VRR and scaling.
- Inner and outer gaps, corner rounding, and drop shadows.
- XDG Desktop Portal for Hyprland integration.
- Stylix gradient active and inactive borders.

______________________________________________________________________

## 🪵 6. Sway (i3-Compatible Wayland Tiling WM)

**Sway** provides a rock-solid, minimalist tiling environment:

- Full i3 compatibility with Wayland performance.
- Declarative monitor outputs and multi-monitor workspace assignments.
- Built-in `swaybg`, `swayidle`, `swaylock`, and `fuzzel` launcher integration.

______________________________________________________________________

## 🌊 7. River (Dynamic Tagging Compositor)

**River** is a flexible, tag-based tiling compositor with `rivertile` layout generator and Stylix color theming.

______________________________________________________________________

## 🥭 8. MangoWC / MangoWM (SceneFX Wayland Compositor)

**MangoWC** is an ultra-fast, dwl-inspired Wayland compositor accelerated by SceneFX for smooth animations and rounded corners with minimal overhead.

______________________________________________________________________

## 🌀 9. Wayfire (3D Compiz-style Wayland Compositor)

**Wayfire** brings 3D effects, desktop cubes, wobbly windows, and fluid animations to Wayland.

______________________________________________________________________

## 🪟 10. Labwc (Openbox-inspired Wayland Stacking Compositor)

**Labwc** provides a lightweight, Openbox-like stacking experience on Wayland.

______________________________________________________________________

## 🐍 11. Qtile (Python-based Dynamic Tiling WM)

**Qtile** is a hackable, highly customizable tiling window manager configured purely in Python with both Wayland and X11 backends.

______________________________________________________________________

## 🧱 12. Classic X11 Window Managers (i3, Bspwm, AwesomeWM, XMonad, DWM, Openbox)

Solar provides modular, out-of-the-box support for the classic X11 window manager pantheon:
- **i3**: Manual tiling with `dmenu` and `picom`.
- **Bspwm**: Binary space partitioning with `sxhkd`.
- **AwesomeWM**: Dynamic Lua-configurable tiling.
- **XMonad**: Haskell dynamic tiling.
- **DWM**: Suckless dynamic tiling.
- **Openbox**: Classic minimalist stacking WM.

______________________________________________________________________

## 🖥️ 13. Traditional Desktop Environments (XFCE, Cinnamon, MATE, LXQt, Budgie)

Solar includes full support for traditional modular desktop environments:
- **XFCE**: Rock-solid modular GTK desktop.
- **Cinnamon**: Modern, feature-rich Linux Mint desktop.
- **MATE**: Traditional GNOME 2 workflow.
- **LXQt**: Ultra-lightweight Qt desktop environment.
- **Budgie**: Elegant Solus-inspired desktop.

______________________________________________________________________

## 📦 14. Preconfigured Suites (`modules/suites/`)

Solar provides high-level suites for a **dendritic workflow**, allowing machines to bundle entire stacks with a single toggle while keeping themes and greeters strictly host-managed:

### Desktop Environment Suites
| Suite | Option | Included Components |
| :--- | :--- | :--- |
| **Niri Desktop Suite** | `myFeatures.suites.desktops.niri` | Niri, Noctalia/Waybar, SwayOSD, Nautilus, Yazi, Audio, Portals |
| **Hyprland Desktop Suite** | `myFeatures.suites.desktops.hyprland` | Hyprland, Waybar, SwayNC, SwayOSD, Nautilus, Yazi, Audio, Portals |
| **Sway Desktop Suite** | `myFeatures.suites.desktops.sway` | Sway, Waybar, SwayNC, SwayOSD, Nautilus, Yazi, Audio, Portals |
| **MangoWC Desktop Suite** | `myFeatures.suites.desktops.mangowc` | MangoWC, SwayOSD, Nautilus, Yazi, Audio, Portals |
| **Wayfire Desktop Suite** | `myFeatures.suites.desktops.wayfire` | Wayfire, Nautilus, Yazi, Audio, Portals |
| **Labwc Desktop Suite** | `myFeatures.suites.desktops.labwc` | Labwc, Waybar, Nautilus, Yazi, Audio, Portals |
| **Qtile Desktop Suite** | `myFeatures.suites.desktops.qtile` | Qtile, Nautilus, Yazi, Audio, Portals |
| **Bspwm Desktop Suite** | `myFeatures.suites.desktops.bspwm` | Bspwm, sxhkd, Nautilus, Yazi, Audio |
| **Awesome Desktop Suite** | `myFeatures.suites.desktops.awesome` | AwesomeWM, Nautilus, Yazi, Audio |
| **i3 Desktop Suite** | `myFeatures.suites.desktops.i3` | i3, Picom, Nautilus, Yazi, Audio |
| **XFCE Desktop Suite** | `myFeatures.suites.desktops.xfce` | XFCE, Thunar, Yazi, Audio, Portals |
| **Cinnamon Desktop Suite** | `myFeatures.suites.desktops.cinnamon` | Cinnamon, Nemo, Yazi, Audio, Portals |
| **MATE Desktop Suite** | `myFeatures.suites.desktops.mate` | MATE, Nautilus, Yazi, Audio, Portals |
| **LXQt Desktop Suite** | `myFeatures.suites.desktops.lxqt` | LXQt, PCManFM, Yazi, Audio, Portals |
| **Budgie Desktop Suite** | `myFeatures.suites.desktops.budgie` | Budgie, Nautilus, Yazi, Audio, Portals |
| **Plasma Desktop Suite** | `myFeatures.suites.desktops.plasma` | KDE Plasma 6, Dolphin, Audio, Portals |
| **GNOME Desktop Suite** | `myFeatures.suites.desktops.gnome` | GNOME Desktop, Nautilus, Audio, Portals |
| **COSMIC Desktop Suite** | `myFeatures.suites.desktops.cosmic` | COSMIC Desktop, Audio, Portals |

### Role & Domain Suites
| Suite | Option | Included Components |
| :--- | :--- | :--- |
| **Workstation Suite** | `myFeatures.suites.workstation` | Ghostty, Helix, Git, Fastfetch, Firefox, Bitwarden, Social, Audio, Udisks2, Portals |
| **Gaming Suite** | `myFeatures.suites.gaming` | Steam + Proton installer, GameScope, Controllers, Mumble, TF2, Social, Audio |
| **Creator Suite** | `myFeatures.suites.creator` | DaVinci Resolve, OBS Studio, VLC, Ani-CLI, Media Tools |
| **Streaming Suite** | `myFeatures.suites.streaming` | Sunshine 48000 streaming host & Moonlight client |
| **Productivity Suite** | `myFeatures.suites.productivity` | AP-Office document authoring & CUPS printing subsystem |
| **Hardened Suite** | `myFeatures.suites.hardened` | AppArmor security profiles & Systemd OOMD daemon |
| **Networking Suite** | `myFeatures.suites.networking` | Tailscale mesh VPN & Systemd-Resolved DNS |
| **Laptop Suite** | `myFeatures.suites.laptop` | Battery management, Bluetooth, WiFi, Trackpad, Idle daemon |
| **Server Suite** | `myFeatures.suites.server` | Hardened SSH, Tailscale, Lix, automated maintenance, CLI tools |
| **Virtualization Suite**| `myFeatures.suites.virtualization` | Podman/Docker, QEMU/KVM, Libvirt, Virt-Manager |
| **Development Suite** | `myFeatures.suites.development` | Direnv, Nix-LD, Git, Helix, NH, Antigravity, Fastfetch |
| **Darwin Workstation** | `myFeatures.suites.darwinWorkstation` | Homebrew, Ghostty, Helix, Antigravity, Fastfetch, AP-Office |

