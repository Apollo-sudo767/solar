# Desktop Environment Suites 🖥️

Solar provides preconfigured desktop suites located under [`modules/suites/desktops/`](file:///Users/apollo/src/solar/modules/suites/desktops) that bundle the window manager, complementary status bars, on-screen displays, file managers, portals, and audio routing into a single declarative toggle.

______________________________________________________________________

## 🗂️ Complete Desktop Suites Matrix

| Suite Name | Suite Toggle | Compositor / WM | Companion Tools Bundled |
| :--- | :--- | :--- | :--- |
| **Niri Suite** | `suites.desktops.niri` | Niri (Scrollable Tiling) | Noctalia v5 / Waybar, SwayOSD, Nautilus, Yazi, Audio, Portals |
| **Hyprland Suite** | `suites.desktops.hyprland` | Hyprland (Dynamic Tiling) | Waybar, SwayNC, SwayOSD, Nautilus, Yazi, Audio, Portals |
| **Sway Suite** | `suites.desktops.sway` | Sway (i3-Compatible) | Waybar, SwayNC, SwayOSD, Nautilus, Yazi, Audio, Portals |
| **MangoWC Suite** | `suites.desktops.mangowc` | MangoWC (SceneFX Tiling) | SwayOSD, Nautilus, Yazi, Audio, Portals |
| **Wayfire Suite** | `suites.desktops.wayfire` | Wayfire (3D Compiz-style) | Nautilus, Yazi, Audio, Portals |
| **Labwc Suite** | `suites.desktops.labwc` | Labwc (Openbox Stacking) | Waybar, Nautilus, Yazi, Audio, Portals |
| **Qtile Suite** | `suites.desktops.qtile` | Qtile (Python Dynamic) | Nautilus, Yazi, Audio, Portals |
| **Bspwm Suite** | `suites.desktops.bspwm` | Bspwm (Binary Space) | sxhkd, Nautilus, Yazi, Audio |
| **Awesome Suite** | `suites.desktops.awesome` | AwesomeWM (Lua Tiling) | Nautilus, Yazi, Audio |
| **i3 Suite** | `suites.desktops.i3` | i3 (Manual Tiling) | Picom, Nautilus, Yazi, Audio |
| **XMonad Suite** | `suites.desktops.xmonad` | XMonad (Haskell Tiling) | Nautilus, Yazi, Audio |
| **DWM Suite** | `suites.desktops.dwm` | DWM (Suckless Tiling) | Nautilus, Yazi, Audio |
| **Openbox Suite** | `suites.desktops.openbox` | Openbox (Stacking) | Nautilus, Yazi, Audio |
| **Plasma Suite** | `suites.desktops.plasma` | KDE Plasma 6 | Dolphin, Audio, Printing, Portals |
| **GNOME Suite** | `suites.desktops.gnome` | GNOME Desktop | Nautilus, Audio, Printing, Portals |
| **COSMIC Suite** | `suites.desktops.cosmic` | COSMIC Desktop (Rust) | Audio, Printing, Portals |
| **XFCE Suite** | `suites.desktops.xfce` | XFCE Desktop | Thunar, Yazi, Audio, Printing |
| **Cinnamon Suite** | `suites.desktops.cinnamon` | Cinnamon Desktop | Nemo, Yazi, Audio, Printing |
| **MATE Suite** | `suites.desktops.mate` | MATE Desktop | Nautilus, Yazi, Audio, Printing |
| **LXQt Suite** | `suites.desktops.lxqt` | LXQt Desktop | PCManFM, Yazi, Audio, Printing |
| **Budgie Suite** | `suites.desktops.budgie` | Budgie Desktop | Nautilus, Yazi, Audio, Printing |

______________________________________________________________________

## 💡 How Desktop Suites Work

When you enable a desktop suite, it configures the full graphic stack with non-invasive `lib.mkDefault` values:

```nix
{
  myFeatures = {
    # 🌲 1. Enable Desktop Suite
    suites.desktops.niri = {
      enable = true;
      shell = "noctalia-v5"; # or "waybar", "noctalia-shell", "none"
    };

    # 🎨 2. Choose Host Aesthetics & Greeter (Strictly Host-Managed)
    platforms.styling = {
      stylix.enable = true;
      flavors.sky.enable = true;
    };
    platforms.addons.displayManager.manager = "regreet";
  };
}
```

### What You Don't Have to Configure Manually:
1. **File Managers**: Installs and configures complementary GUI and TUI file managers (Nautilus + Yazi, Dolphin, or Thunar) with full thumbnail generation.
2. **Audio & Media Routing**: Automatically links PipeWire audio routing and volume keys to on-screen feedback (`swayosd`).
3. **Screen Sharing & Portals**: Automatically configures the appropriate XDG Desktop Portal backend (e.g. `xdg-desktop-portal-gnome`, `xdg-desktop-portal-wlr`, `xdg-desktop-portal-kde`, or `xdg-desktop-portal-hyprland`).
