# Shell, Bar & Desktop Addons 🧩

Solar provides a rich ecosystem of declarative addons, greeters, status bars, notification daemons, and screen lockers.

______________________________________________________________________

## 🚪 1. Display Managers & Greeters

Managed declaratively through `myFeatures.platforms.addons.displayManager`:

| Manager | Option Name | Primary Desktop Target | Description |
| :--- | :--- | :--- | :--- |
| **ReGreet** | `manager = "regreet"` | Niri / Standalone Wayland | Modern GTK4 Wayland greeter styled with Stylix themes. |
| **SDDM** | `manager = "sddm"` | KDE Plasma 6 | Qt6-based display manager with theme integration. |
| **GDM** | `manager = "gdm"` | GNOME | GNOME Display Manager with Wayland session support. |
| **COSMIC** | `manager = "cosmic-greeter"` | COSMIC Desktop | Rust-based greeter with biometric & password unlock. |

______________________________________________________________________

## 🐚 2. Shell & Bar Modules

### Noctalia Shell & Noctalia v5

- High-performance, aesthetic shell overlay and quick-settings widgets for modern Wayland compositors.
- Deep integration with Solar flavor presets (`skyNoctalia`, `gruvboxNoctalia`).

### Waybar

- Highly customizable GTK3 status bar configured with hardware monitoring (CPU/GPU temperature, RAM usage, audio volume, network status, battery level, and active workspace tracking).

### Ironbar

- Modern, CSS-styled status bar built in Rust, providing popup menus, system trays, and media players.

______________________________________________________________________

## 🔔 3. System Feedback & Utilities

- **SwayNC (Sway Notification Center)**: GTK notification daemon with slide-out widget panel, Do Not Disturb toggles, and media controls.
- **SwayOSD**: On-screen display overlays for volume, brightness, caps-lock, and microphone mute events.
- **Fuzzel**: Fast, minimalist Wayland application launcher with fuzzy matching and dmenu replacement.
- **SWWW & Swaybg**: Smooth GPU-accelerated wallpaper daemons with animated transitions.
- **Swaylock / Hypridle**: Automatic screen locking, display dimming, and DPMS sleep timeouts after user inactivity.
