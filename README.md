# Solar ☀️
____

## ❄️ Fully Automated Dendretic Flake   
A NixOS configuration that is structured like a tree \| Modular, Automated, and purely nix declarative   

![limine-bg](assets/wallpapers/limine-bg.png)    
## 🌲 The Dendretic Tree   
New Features and Hosts are automatically discovered and integrated. This structure treats the fleet of machines it serves as a single unified module tree.

````text
Solar
├── flake.nix               # Project entry point & host loader
├── flake.lock              # Version-locked inputs
├── assets/                 # Wallpapers & branding
│   └── wallpapers/
├── modules/                # The Dendritic Core
│   ├── default.nix         # Recursive autoscanner (ignores /hosts)
│   ├── core/               # System essentials (boot, users, etc.)
│   ├── hardware/           # Hardware-specific modules
│   ├── programs/           # Toggleable feature modules
│   ├── services/           # Background system services
│   ├── systems/            # Desktop environments (Niri, Gnome)
│   └── hosts/              # The Terminal Leaves (Machine Definitions)
│       ├── default.nix     # Manual host loader logic
│       ├── mars/
│       ├── mercury/
│       └── venus/
├── parts/                  # Flake-parts plumbing
└── templates/              # Quick-start boilerplates
````
   
## 🎨 Visual Styling   
Managed via **Stylix**. Wallpapers and themes are centralized in the `assets/` folder.   
![Screenshot from 2026-04-06 23-29-40](assets/screenshots/ss1.png)    
![Screenshot from 2026-04-06 23-30-15](assets/screenshots/ss2.png)    
![Screenshot from 2026-04-06 23-30-27](assets/screenshots/ss3.png)    
   
## 🚀 Enabling Features   
Every module in the /modules directory can be enabled through   
```
# Inside modules/hosts/<hostname>/default.nix
myFeatures.programs.niri.enable = true;
```
## ⚒️Deployment Instructions   
To apply a configuration to a machine for the first time run   
```
sudo nixos-rebuild boot --flake .#<hostname>
```
To update a machine enter   
```
nix flake update
nrs
# Or, if you'd like to update system without rebooting
nrb
```
   
