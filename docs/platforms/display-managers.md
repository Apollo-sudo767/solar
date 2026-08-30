# Display Managers & Greeters 🚪

Display managers (login greeters) in Solar are managed declaratively through `myFeatures.platforms.addons.displayManager`.

> [!IMPORTANT]
> **Strict Host Ownership**: In Solar's dendritic architecture, display managers are **never** declared inside suites. Each machine explicitly declares its preferred greeter inside its host file (`modules/hosts/<hostname>/default.nix`).

______________________________________________________________________

## 🗂️ Supported Display Managers & Greeters

| Greeter Name | Option Value | Backend | Typical Use Cases |
| :--- | :--- | :--- | :--- |
| **ReGreet** | `manager = "regreet"` | GTK4 / Cage (Wayland) | Modern Wayland workstations (**Mars**, **Mercury**), Niri, Hyprland, Sway |
| **SDDM** | `manager = "sddm"` | Qt6 / Wayland | KDE Plasma 6 rigs (**Elara**, **Europa**, **Amalthea**) |
| **GDM** | `manager = "gdm"` | GTK4 (Wayland) | GNOME desktop environments |
| **COSMIC Greeter** | `manager = "cosmic-greeter"` | Rust / Iced (Wayland) | COSMIC desktop environments (**Io**) |
| **Tuigreet** | `manager = "tuigreet"` | TUI / Console | Lightweight, minimalist, terminal-based greeter |
| **LightDM** | `manager = "lightdm"` | GTK (X11) | Classic X11 desktops (XFCE, MATE, i3, Openbox) |

______________________________________________________________________

## 🛠️ Configuration Syntax

Set your machine's display manager under `platforms.addons.displayManager.manager` in your host configuration:

```nix
# modules/hosts/<hostname>/default.nix
{
  myFeatures.platforms.addons.displayManager = {
    manager = "regreet"; # "regreet", "sddm", "gdm", "cosmic-greeter", "tuigreet", "lightdm"
  };
}
```

### Auto-Login Configuration
For handheld devices or kiosks (**Amalthea**):
```nix
services.displayManager.autoLogin = {
  enable = true;
  user = "apollo";
};
```
