# Wayland Compositors 🌊

Solar provides first-class, declarative support for the leading modern Wayland window managers and scrollable compositors.

______________________________________________________________________

## 1. Niri (Infinite Scrollable Tiling)

**Niri** is the flagship compositor for Solar workstations (**Mars** and **Mercury**). It features an infinite horizontal ribbon layout where windows are tiled onto scrollable columns.

- **Option**: `myFeatures.platforms.desktops.niri.enable = true;` (or `suites.desktops.niri.enable = true;`)
- **Declarative Monitors**: Resolves physical EDID names, preset resolutions (`1440p`, `1080p`, `4k`), refresh rates, orientation (`horizontal`, `vertical`), and Variable Refresh Rate (VRR/FreeSync/G-Sync).
- **Layout Customization**: `modKey`, `defaultColumnWidth`, `gaps`, and multi-monitor assignments.

```nix
myFeatures.platforms.desktops.niri = {
  enable = true;
  modKey = "super";
  defaultColumnWidth = 1.0;
  monitors = [
    {
      name = "DP-1";
      resolution = "1440p";
      refresh = 180.0;
      orientation = "horizontal";
      vrr = true;
      primary = true;
    }
  ];
};
```

______________________________________________________________________

## 2. Hyprland (Dynamic Tiling with Fluid Animations)

**Hyprland** provides a highly customizable dynamic tiling environment with smooth physics-based animations, background blur, rounded corners, and drop shadows.

- **Option**: `myFeatures.platforms.desktops.hyprland.enable = true;` (or `suites.desktops.hyprland.enable = true;`)
- **Key Features**:
  - Declarative monitor list with scaling and VRR.
  - Inner and outer gaps, border sizes, and corner radius.
  - Custom animation presets (`smooth`, `snappy`).
  - Automatic Stylix gradient borders matching your active color theme.

```nix
myFeatures.platforms.desktops.hyprland = {
  enable = true;
  modKey = "SUPER";
  gapsIn = 5;
  gapsOut = 10;
  rounding = 10;
  monitors = [
    { name = "DP-1"; resolution = "2560x1440@180"; position = "0x0"; scale = "1.0"; vrr = 1; }
  ];
};
```

______________________________________________________________________

## 3. Sway (i3-Compatible Wayland Tiling WM)

**Sway** provides a drop-in Wayland replacement for the classic i3 window manager.

- **Option**: `myFeatures.platforms.desktops.sway.enable = true;` (or `suites.desktops.sway.enable = true;`)
- **Key Features**:
  - Declarative monitor configuration with custom wallpaper and output modes.
  - Built-in `swaybg`, `swayidle`, `swaylock`, and `fuzzel` launcher integration.
  - Configurable modifier key (`Mod4` or `Mod1`), window gaps, and titlebar styling.

______________________________________________________________________

## 4. MangoWC / MangoWM (Ultra-Fast SceneFX Compositor)

**MangoWC** is a lightweight, modern Wayland compositor built with wlroots and SceneFX, delivering smooth animations and rounded corners with minimal CPU overhead.

- **Option**: `myFeatures.platforms.desktops.mangowc.enable = true;` (or `suites.desktops.mangowc.enable = true;`)
- **Key Features**:
  - Native SceneFX hardware-accelerated animations.
  - Inner/outer window gaps and customizable border colors.
  - Wayland native XDG desktop portal integration.

______________________________________________________________________

## 5. River (Dynamic Tag-Based Compositor)

**River** is a flexible, dynamic tiling Wayland compositor that uses tags instead of traditional static workspaces.

- **Option**: `myFeatures.platforms.desktops.river.enable = true;`
- **Key Features**:
  - Modular layout generator via `rivertile`.
  - Rich tag-based window manipulation and multi-tag views.
  - Declarative border colors and layout gaps.

______________________________________________________________________

## 6. Wayfire (3D Compiz-Style Wayland Compositor)

**Wayfire** brings classic 3D effects, desktop cubes, wobbly windows, and fluid animations to modern Wayland.

- **Option**: `myFeatures.platforms.desktops.wayfire.enable = true;`
- **Key Features**:
  - Wobbly windows, cube workspace switcher, and zoom plugins.
  - Compatible with standard Wayland status bars (Waybar, Ironbar).

______________________________________________________________________

## 7. Labwc (Openbox-Inspired Stacking Compositor)

**Labwc** is a lightweight, stacking Wayland compositor inspired by Openbox with low resource consumption.

- **Option**: `myFeatures.platforms.desktops.labwc.enable = true;`
- **Key Features**:
  - Openbox XML-style theme support.
  - Snappy window stacking and snapping.

______________________________________________________________________

## 8. Qtile Wayland (Python-Scripted Tiling WM)

**Qtile** is a full-featured, hackable tiling window manager configured purely in Python with both Wayland and X11 backends.

- **Option**: `myFeatures.platforms.desktops.qtile.enable = true;`
