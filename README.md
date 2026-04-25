# Solar ☀️
____

## ❄️ Fully Automated Dendretic Flake   
A NixOS configuration that is structured like a tree \| Modular, Automated, and purely nix declarative   

![limine-bg](assets/wallpapers/limine-bg.png)    
## 🌲 The Dendretic Tree   
New Features and Hosts are automatically discovered and integrated. This structure treats the fleet of machines it serves as a single unified module tree.

````text
Solar
├── flake.nix               # Entry point (now generates both nixosConfigurations and darwinConfigurations)
├── flake.lock
├── assets/
├── modules/                # The Dendritic Core
│   ├── default.nix         # UPDATED: Autoscanner that filters based on 'isDarwin' and 'isTotal'
│   ├── core/               # Cross-platform system essentials (users, nix-settings, etc.)
│   ├── darwin/             # NEW: macOS-exclusive settings (Homebrew, Mac defaults)
│   ├── hardware/           # Linux-exclusive hardware logic (stays hidden from Mac)
│   ├── programs/           # Feature modules (Fastfetch, Helix, etc. marked as 'isTotal')
│   ├── services/           # System services (Nginx, Tailscale, etc.)
│   ├── systems/            # Desktop & Style (Stylix, Niri, Waybar)
│   └── hosts/              # The Terminal Leaves
│       ├── default.nix     # UPDATED: Dual-purpose host loader for NixOS and Darwin
│       ├── mars/           # NixOS Host
│       ├── phobos/         # NEW: Darwin Host (MacBook)
│       └── venus/          # NixOS Host
├── parts/
└── templates/
````
   
## 🎨 Visual Styling   
Managed via **Stylix**. Wallpapers and themes are centralized in the `assets/` folder.   
![Screenshot from 2026-04-06 23-29-40](assets/screenshots/ss1.png)    
![Screenshot from 2026-04-06 23-30-15](assets/screenshots/ss2.png)    
![Screenshot from 2026-04-06 23-30-27](assets/screenshots/ss3.png)    
   
## 🚀 Enabling Features   
Every module in the /modules directory can be enabled through (with the Niri feature module as an example)
```
# Inside modules/hosts/<hostname>/default.nix
myFeatures.systems.niri.enable = true;
```
## ⚒️Deployment Instructions   
To apply a configuration to a machine for the first time run   
```
sudo nixos-rebuild boot --flake .#<hostname>
```
To update a machine enter   
```
# First to Update Flake Inputs (This puts you on the latest version)
nix flake update
# And then to do a live update to the system
nrs
# Or, if you'd like to update system that only applies changes after a reboot
nrb
```
   
