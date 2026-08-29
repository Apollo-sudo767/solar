# Styling, Themes & Flavors 🎨

Styling in Solar is orchestrated through **Stylix** combined with custom **Flavors** that deliver consistent palettes, wallpapers, fonts, window borders, and UI accents across all applications.

______________________________________________________________________

## 🌈 The Preset Themes

Solar includes five handcrafted base themes under `myFeatures.platforms.styling.themes.<name>`:

| Theme | Wallpaper | Palette Highlights | Host Defaults |
| :--- | :--- | :--- | :--- |
| **`sky`** | Space & Sky artwork | Clean cyan, deep blue, crisp whites | `mars`, `mercury` |
| **`gruvbox`** | Gruvbox warm vector art | Retro warm earth tones, orange, amber | Workstations (Alternative) |
| **`strawberry`** | Strawberry aesthetic | Soft pinks, pastel reds, elegant dark slate | `elara` |
| **`forest`** | Deep forest canopy | Emerald greens, moss tones, soothing darks | `europa` |
| **`space`** | Solar orbit artwork | Cosmic indigo, purple, starlight white | `io` |

______________________________________________________________________

## 🍧 Desktop Flavors

A **Flavor** in Solar goes beyond colors by configuring complete compositor aesthetics:

- **Window Borders & Gaps**: Active window highlights, rounded corner radii, and drop shadows.
- **Noctalia Integration**: Custom QML/CSS widgets, blur radius settings, and system tray styling.
- **Font Typography**: Consistent font sizes across TTY, GTK, Qt, Ghostty, Helix, and browsers using Nerd Fonts.
- **Shell Theming**: Starship prompt colors matching the active flavor.

### Enabling a Flavor:

```nix
myFeatures.platforms.styling = {
  stylix.enable = true;
  flavors.sky.enable = true; # or flavors.gruvbox.enable = true
};
```
