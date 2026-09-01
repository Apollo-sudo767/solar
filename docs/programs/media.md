# Media Production & Creation 🎬

Solar provisions professional creative software, GPU-accelerated video editors, broadcast tools, and media players.

______________________________________________________________________

## 🎨 Creative Software Stack

### 1. DaVinci Resolve Studio (`davinci.nix`)

- Industry-standard professional video editing, color grading, visual effects, and audio post-production.
- Hardware-accelerated with Nvidia CUDA and AMD ROCm GPU compute engines.

### 2. OBS Studio (`obs.nix`)

- Complete broadcasting and screen recording suite.
- Native Linux VAAPI and NVENC hardware encoder support.
- Direct PipeWire audio capture and Wayland screen capture (`wlrobs`).

### 3. MPV & IMV (`media.nix`)

- **MPV**: Configured with `gpu-hq` profile, `hwdec = auto-safe`, and dynamic YouTube-DL 1440p/4K format selection.
- **IMV**: Ultra-fast Wayland image viewer.

### 4. VLC & Ani-CLI (`vlc.nix` & `ani-cli.nix`)

- **VLC**: Universal media player.
- **ani-cli**: Fast, terminal-based anime streamer using MPV as the playback engine.
