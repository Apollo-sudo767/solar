# Full Desktop Environments 🖥️

Solar provides complete, turn-key integrations for the major Linux desktop environments across modern Wayland and classic X11 platforms.

______________________________________________________________________

## 🗂️ Desktop Environments Overview

| Desktop Environment | Option Path | Toolkit | Session Type | Key Characteristics |
| :--- | :--- | :--- | :--- | :--- |
| **KDE Plasma 6** | `myFeatures.platforms.desktops.kde` | Qt6 / KF6 | Pure Wayland | Flagship gaming DE (**Elara**, **Europa**, **Amalthea**), HDR support, fractional scaling. |
| **GNOME** | `myFeatures.platforms.desktops.gnome` | GTK4 / Libadwaita | Wayland / X11 | Clean modern shell, GDM integration, distraction-free workflow. |
| **COSMIC** | `myFeatures.platforms.desktops.cosmic` | Rust / Iced | Pure Wayland | Next-gen System76 desktop (**Io**), ultra-responsive, built-in tiling. |
| **XFCE** | `myFeatures.platforms.desktops.xfce` | GTK3 | X11 | Rock-solid, ultra-lightweight, modular desktop with Thunar file manager. |
| **Cinnamon** | `myFeatures.platforms.desktops.cinnamon` | GTK3 | X11 / Wayland | Traditional, familiar Linux Mint desktop with Nemo file manager. |
| **MATE** | `myFeatures.platforms.desktops.mate` | GTK3 | X11 | Classic GNOME 2 fork with low resource usage and Caja file manager. |
| **LXQt** | `myFeatures.platforms.desktops.lxqt` | Qt6 | X11 / Wayland | Extremely lightweight Qt desktop for resource-constrained hardware. |
| **Budgie** | `myFeatures.platforms.desktops.budgie` | GTK3 / Libadwaita | X11 | Elegant, modern desktop environment inspired by Solus. |

______________________________________________________________________

## ⚙️ Configuration Examples

### 1. KDE Plasma 6
```nix
myFeatures.platforms = {
  desktops.kde = {
    enable = true;
    karousel.enable = false; # Optional scrollable tiling KWin script
  };
  addons.displayManager.manager = "sddm";
  styling = {
    stylix.enable = true;
    themes.strawberry.enable = true;
  };
};
```

### 2. GNOME
```nix
myFeatures.platforms = {
  desktops.gnome.enable = true;
  addons.displayManager.manager = "gdm";
  styling = {
    stylix.enable = true;
    flavors.sky.enable = true;
  };
};
```

### 3. COSMIC Desktop
```nix
myFeatures.platforms = {
  desktops.cosmic.enable = true;
  addons.displayManager.manager = "cosmic-greeter";
  styling = {
    stylix.enable = true;
    themes.space.enable = true;
  };
};
```
