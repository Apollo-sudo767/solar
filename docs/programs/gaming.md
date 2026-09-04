# Gaming & Esports Suite 🎮

Solar features a dedicated, performance-tuned gaming and esports stack supporting native Linux titles, Steam Proton, competitive esports, and modded Minecraft.

______________________________________________________________________

## 🎯 1. Competitive Team Fortress 2 Suite (`tf2.nix`)

The competitive TF2 suite (`myFeatures.programs.media.tf2`) provisions a complete tournament toolchain for leagues like **RGL.gg**, **ETF2L**, **TF2Center**, and PUG lobbies:

### Included Tools:

- **`tf2-rcon`**: Scrim and match server administration helper:
  ```bash
  # Execute tournament league configs
  tf2-rcon exec rgl_6s_5cp
  # Match control
  tf2-rcon pause
  tf2-rcon unpause
  tf2-rcon restart
  # Set server password
  tf2-rcon pass <secret>
  ```
- **`tf2-comp-setup`**: Automated config and autoexec generator:
  - `tf2-comp-setup --install-autoexec`: Installs competitive network interpolation rates (66-tick, 196608 rate, projectile vs hitscan interp aliases), null-cancelling movement script, Medic Uber radar (`+radar` on `C`), automatic match demo recording (`ds_enable 2`), damage batching, and hitsound scaling.
  - `tf2-comp-setup --install-null-move`: Deploys standalone `null_movement.cfg`.
  - `tf2-comp-setup --launch-options`: Displays optimal Linux 64-bit Vulkan launch arguments.
  - `tf2-comp-setup --huds`: Displays guides and links for competitive HUDs (budhud, mastercomhud, ahud, toonhud).
- **`tf2-logs` & `tf2-demos`**: Instant CLI lookup tools for matches on `logs.tf` and `demos.tf`.
- **`vpkedit`**: Modern GUI and CLI tool for unpacking, customizing, and building VPK archives for HUDs, hitsounds, and crosshairs.

______________________________________________________________________

## 🎙️ 2. Mumble VoIP Module (`mumble.nix`)

**Mumble** (`myFeatures.programs.media.mumble`) is the standard voice client for competitive TF2 scrims and tournament matches.

- **Wayland Global Push-to-Talk**: Automatically configures the `input` group on Linux hosts so Mumble can capture global Push-to-Talk hotkeys via `evdev` even when games or other apps have window focus under Niri/Wayland.
- **Positional Audio**: Native integration with the Source Engine Link plugin (`hl2_linux`).
- **In-Game Overlay**: Optional `mumble_overlay` integration.
- **State Preservation**: Persists user certificates, server bookmarks, and audio settings across reboots.

______________________________________________________________________

## 🚀 3. Steam & Gamescope Optimization (`steam.nix`)

Configured via `myFeatures.programs.media.steam`:

- **Native Wrapper**: Wrapped Steam launcher integrating OpenXR runtimes and dynamic desktop shortcut synchronization (`steam-desktop-sync`).
- **Gamescope Session**: Launch games or Steam directly inside the Gamescope micro-compositor with integer scaling, FSR upscaling, and custom resolutions.
- **ProtonUp-Qt / ProtonPlus**: GUI Proton installer for GE-Proton, Proton-TKG, and custom compatibility tools.
- **GameMode & MangoHud**: Automatic CPU governor performance tuning and onscreen FPS/frametime monitoring.
- **Dual-Drive Storage**: Automatically separates fast primary games on NVMe (`~/.local/share/Steam`) from bulk secondary storage on HDDs (`~/.local/share/SteamBulk`).

______________________________________________________________________

## ⛏️ 4. Minecraft Suite (`minecraft.nix`)

Unified Minecraft module providing declarative Java and Bedrock Edition launchers (`myFeatures.programs.media.minecraft`):

### Java Edition (`minecraft.java`):

- **Prism Launcher**: Open-source launcher with multi-instance support and automatic JDK runtime packaging:
  - **Temurin JDK 21**: Modern Minecraft (1.20.5+).
  - **Temurin JDK 17**: Intermediate versions (1.17 - 1.20.4).
  - **OpenJDK 8**: Classic and legacy modpacks (1.16.5 and below).
- **State Preservation**: Persists instances and configurations in `~/.local/share/PrismLauncher` and `~/.config/PrismLauncher`.

### Bedrock Edition (`minecraft.bedrock`):

Supports both native Windows Bedrock (via BedrockOnLinux) and Android Bedrock (via MCPELauncher):

- **Edition Toggle (`minecraft.bedrock.edition`)**:
  - `windows` (Default): Uses **BedrockOnLinux** to run native Minecraft Bedrock for Windows (GDK) on Linux with official Xbox Live login, Realms, servers, and Friends.
  - `android`: Uses **MCPELauncher** via Flatpak (`io.mrarm.mcpelauncher`) running the Google Play Android build.
  - `both`: Installs and configures both runtimes side by side.
- **BedrockOnLinux (`minecraft.bedrock.windows` / `bedrockOnLinux`)**:
  - Native Python/Proton GDK launcher with `bedrock-on-linux` and `bedrockonlinux` CLI commands and desktop entry.
  - **State Preservation**: Persists game installations, prefix, and settings in `~/.local/share/bedrock-on-linux` and `~/.config/bedrock-on-linux`.
- **MCPELauncher (`minecraft.bedrock.android` / `mcpelauncher`)**:
  - Declarative Flatpak package (`io.mrarm.mcpelauncher`) with `mcpelauncher` and `mcpelauncher-ui-qt` wrapper scripts.
  - **State Preservation**: Persists game data, worlds, and settings in `~/.var/app/io.mrarm.mcpelauncher`.

______________________________________________________________________

## 🤖 5. Roblox (`roblox.nix`)

Native Linux runtime for **Roblox** (`myFeatures.programs.media.roblox`):

- **Declarative Flatpak Management**: Managed via `nix-flatpak` using the `org.vinegarhq.Sober` Flathub package.
- **CLI Wrapper**: Provides convenient `sober` command forwarding arguments and URLs directly to the runtime.
- **State Preservation**: Persists authentication and configuration in `~/.var/app/org.vinegarhq.Sober` across reboots on ephemeral roots.
