# Multimedia & Game Streaming 🔊

Solar configures low-latency audio processing and game broadcasting daemons.

______________________________________________________________________

## 🎧 1. PipeWire Audio Stack (`audio.nix`)

Solar features a real-time, low-latency PipeWire audio architecture:

- **Universal Backends**:
  - `pipewire.alsa.enable` with 32-bit compatibility for legacy games and Steam Proton.
  - `pipewire.pulse.enable` for PulseAudio client compatibility.
  - `pipewire.jack.enable` for professional DAW and low-latency audio workflows.
- **Real-Time Priority**: `security.rtkit.enable = true` prevents audio stutter and buffer underruns under heavy CPU load.
- **State Preservation**: Persists WirePlumber volume states and device routing in `~/.local/state/wireplumber`.

______________________________________________________________________

## 🎮 2. Sunshine Game Streaming Server (`sunshine.nix`)

Sunshine transforms **Mars** and **Elara** into high-performance cloud gaming servers:

- **Low-Latency Streaming**: Up to 4K 120fps HDR video streaming to Moonlight clients (Steam Deck, laptops, TVs, phones).
- **Hardware Acceleration**: Automatic Nvidia CUDA and NVENC hardware encoder selection.
- **Virtual Input**: `uinput` kernel module and controller emulation rules for Xbox and DualShock input handling.
- **Gamescope Mode**: Seamlessly launches games into dedicated Gamescope sessions for clean resolution switching.
