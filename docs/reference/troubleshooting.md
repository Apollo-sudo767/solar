# Troubleshooting & Diagnostics 🔧

Common diagnostic runbooks and disaster recovery solutions in Solar.

______________________________________________________________________

## 🖥️ Boot & Display Failures

### 1. Black Screen / Display Manager Failed

If booting to a black screen after an update:

1. Switch to a TTY console using <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>F3</kbd>.
1. Log in and inspect the display manager journal:
   ```bash
   journalctl -u greetd -e --no-pager
   journalctl -u display-manager -e --no-pager
   ```
1. Roll back to the prior working generation from the Limine bootloader menu.

### 2. Nvidia Driver Mismatch

If the kernel was updated without rebuilding the proprietary Nvidia kernel module:

```bash
# Check if nvidia modules loaded
lsmod | grep nvidia

# Rebuild host configuration cleanly
nh os switch . -H <hostname>
```

______________________________________________________________________

## 💾 Storage & Impermanence Issues

### 1. File Not Persisting Across Reboots

On ephemeral hosts (`mars`, `mercury`, `pluto`), unmanaged files in `/` disappear on reboot:

1. Verify if the path is listed in `preservation.preserveAt`.
1. Move state into `/persist/home/apollo/` and symlink:
   ```bash
   mkdir -p /persist/home/apollo/.config/myapp
   ln -s /persist/home/apollo/.config/myapp ~/.config/myapp
   ```

### 2. Btrfs Space Exhaustion

If a Btrfs subvolume enters emergency read-only mode:

```bash
# Check disk usage
sudo btrfs filesystem usage /

# Balance metadata
sudo btrfs balance start -dusage=5 /persist
```

______________________________________________________________________

## 🌐 Tailscale & Mesh Networking

### 1. Node Appears Offline

```bash
# Check service status
sudo systemctl status tailscale

# Re-authenticate node
sudo tailscale up --ssh --operator=apollo
```

### 2. DNS Failures (`.local` or MagicDNS)

```bash
# Flush and restart resolved
resolvectl flush-caches
sudo systemctl restart systemd-resolved
```
