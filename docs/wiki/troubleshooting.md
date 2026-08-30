# Troubleshooting & Diagnostics 🔧

Solutions to common issues, recovery procedures, and diagnostic steps across the Solar fleet.

______________________________________________________________________

## 🖥️ Graphical & Display Issues

### 1. Black Screen on Nvidia GPUs
If a display fails to light up on Nvidia hardware after a kernel update:
1. Verify open kernel modules: Ensure `hardware.cpu-gpu.nvidia.open = true` is set for Turing+ GPUs (GTX 16xx, RTX 20xx+).
2. For legacy Maxwell/Pascal GPUs (GTX 9xx/10xx), set `open = false; legacy = true;`.
3. Check DRM modesetting: Ensure `KWIN_DRM_USE_MODIFIERS = "1"` or `NVD_BACKEND = "direct"` is set if running Wayland.

### 2. Monitor Not Detected or Wrong Refresh Rate in Niri
1. Run `niri msg outputs` in terminal to view physical EDID names and connector IDs (e.g. `DP-1`, `HDMI-A-1`).
2. Update the `name` or `aliases` list in `platforms.desktops.niri.monitors` with the physical device identifier.
3. Reload Niri live without restarting:
   ```bash
   niri msg action reload-config
   ```

______________________________________________________________________

## 🔊 Audio & PipeWire Troubleshooting

### 1. No Audio Output or Stalled Streams
Restart the user PipeWire stack:
```bash
systemctl --user restart pipewire pipewire-pulse wireplumber
```

### 2. Inspect Audio Devices & Volume Nodes
```bash
wpctl status
```
Set default audio sink:
```bash
wpctl set-default <sink-id>
```

______________________________________________________________________

## 💾 Storage, Impermanence & Btrfs

### 1. File Not Persisting Across Reboots
If a file or config disappears after reboot on ephemeral hosts (`mars`, `mercury`):
1. Check if the directory is listed in the module's `preservation.preserveAt` list.
2. Manually symlink to `/persist`:
   ```bash
   mkdir -p /persist/home/apollo/.config/myapp
   ln -s /persist/home/apollo/.config/myapp ~/.config/myapp
   ```

### 2. Btrfs Read-Only or Space Exhaustion
If a Btrfs filesystem enters emergency read-only mode:
```bash
# Check filesystem space
sudo btrfs filesystem usage /

# Balance metadata
sudo btrfs balance start -dusage=5 /persist
```

______________________________________________________________________

## 🌐 Networking & Tailscale

### 1. Tailscale Node Offline or Key Expired
Re-authenticate with:
```bash
sudo tailscale up --operator=apollo
```

### 2. DNS Resolution Failures
Flush and restart Systemd-Resolved:
```bash
resolvectl flush-caches
sudo systemctl restart systemd-resolved
```
