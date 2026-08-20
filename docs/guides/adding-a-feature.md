# Adding a New Feature Module 🧩

Every reusable tool, service, desktop environment, or hardware profile is represented as a self-contained module under `/modules`.

______________________________________________________________________

## 📂 Category Placement

Select the appropriate subdirectory under `/modules`:

- `modules/programs/`: User applications (CLI tools, GUI apps, media, office).
- `modules/services/`: Daemons, servers, networking, and hardware background tasks.
- `modules/platforms/`: Window managers, desktop environments, display managers, and themes.
- `modules/hardware/`: Device-specific hardware drivers, GPUs, and peripherals.
- `modules/core/`: Fleet-wide foundational modules.

______________________________________________________________________

## 📝 Module Anatomy

Create a new file (e.g. `modules/programs/terminal/mytool.nix`):

```nix
{ config, lib, pkgs, isDarwin, isTotal, ... }:
let
  cfg = config.myFeatures.programs.terminal.mytool;
in
{
  options.myFeatures.programs.terminal.mytool = {
    enable = lib.mkEnableOption "My Custom CLI Tool";
  };

  config = lib.mkIf cfg.enable {
    # System packages installed across all platforms
    environment.systemPackages = [ pkgs.mytool ];

    # Home Manager configuration for users
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      programs.mytool = {
        enable = true;
      };
    });

    # Persistence for stateful directories (Linux wipe-on-boot)
    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && !isDarwin) {
        users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
          directories = [ ".config/mytool" ];
        });
      };
  };
}
```

______________________________________________________________________

## ⚡ Instant Integration

Because of the Dendritic Autoscanner (`modules/default.nix`), you do **not** need to register your new file in any list or import array. Simply save the `.nix` file and enable it in any host:

```nix
myFeatures.programs.terminal.mytool.enable = true;
```
