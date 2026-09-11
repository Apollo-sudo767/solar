# How Modules Work ⚙️

Every feature module in Solar is designed around three principles: **composability**, **multi-user Home Manager awareness**, and **cross-platform adaptability**.

______________________________________________________________________

## 🧩 Module Blueprint

A typical Solar module looks like this:

```nix
# modules/programs/terminal/mytool.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.programs.terminal.mytool;
in
{
  options.myFeatures.programs.terminal.mytool = {
    enable = lib.mkEnableOption "mytool CLI helper";
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra configuration appended to mytool config";
    };
  };

  config = lib.mkIf cfg.enable {
    # System-level packages
    environment.systemPackages = [ pkgs.mytool ];

    # User-level configuration via multi-user helper
    userScope = {
      xdg.configFile."mytool/config.toml".text = ''
        verbose = true
        ${cfg.extraConfig}
      '';
    };

    # State preservation on ephemeral hosts
    preservation.preserveAt = [
      "home/.config/mytool"
    ];
  };
}
```

______________________________________________________________________

## 👥 Multi-User Home Manager Injection (`userScope`)

Instead of writing repetitive `home-manager.users.<username>` blocks across dozens of user accounts, Solar provides a universal `userScope` attribute.

When declared:

1. Solar queries `config.myFeatures.core.system.users.usernames`.
1. The attributes declared inside `userScope` are injected cleanly across **all active declared users**.
1. Dotfiles, shell integrations, and XDG configurations remain consistent across user profiles.

______________________________________________________________________

## 🎨 Stylix Theming Integration

Desktop and compositor styling is centralized using **Stylix**:

```nix
# Enable Stylix and a theme
myFeatures.styling = {
  stylix.enable = true;
  themes.sky.enable = true; # or strawberry, gruvbox, forest, space
};
```

Stylix automatically generates and applies matching themes across:

- **Display Managers**: ReGreet, SDDM, GDM, COSMIC Greeter
- **Compositors & WMs**: Niri, KDE Plasma 6, Hyprland
- **Terminals**: Ghostty, Foot, Alacritty
- **Editors**: Helix, Neovim
- **Shell Prompts**: Starship, Bat, Fzf
- **Wallpapers & Fonts**: Declared system-wide with automatic font scaling
