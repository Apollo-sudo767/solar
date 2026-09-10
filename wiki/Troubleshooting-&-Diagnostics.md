# Troubleshooting & Diagnostics 🔧

Diagnostic procedures, emergency rescue workflows, and recovery runbooks for the Solar ecosystem.

______________________________________________________________________

## 🖥️ Graphical & Compositor Recovery

### Black Screen on Boot (Nvidia / DRM)

If your display manager fails to start after a kernel or driver update:

1. Switch to a TTY via <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>F3</kbd>.
1. Log in with your user credentials.
1. Check the display manager and compositor logs:
   ```bash
   journalctl -u greetd.service -b 0 --no-pager
   ```
1. Roll back to the previous known-good NixOS generation directly from the bootloader menu (Limine), or run:
   ```bash
   sudo nix-env --rollback -p /nix/var/nix/profiles/system
   sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
   ```

### Reset Broken Wayland Compositor Configs

If a compositor (Niri, Hyprland, Sway) fails to load due to a syntax error:

```bash
# Check configuration syntax
niri validate

# Emergency launch into bare Wayland shell
niri --wayland-display-name emergency-session
```

______________________________________________________________________

## 💾 Storage & Filesystem Recovery

### Emergency Btrfs Repair

If a Btrfs filesystem refuses to mount read-write due to corruption or dirty shutdown:

```bash
# 1. Mount read-only with emergency recovery flags
sudo mount -o ro,recovery,usebackuproot /dev/mapper/cryptroot /mnt

# 2. Check filesystem health without modifying
sudo btrfs check --readonly /dev/mapper/cryptroot

# 3. Scrub and correct checksum errors online
sudo btrfs scrub start /persist
sudo btrfs scrub status /persist
```

### TPM 2.0 Auto-Unlock Failure

If PCR values change after a firmware/BIOS update, TPM auto-unlock may prompt for your manual passphrase:

1. Enter your manual LUKS disk passphrase at the emergency prompt.
1. Once booted into the system, re-enroll TPM 2.0 with current hardware PCR registers:
   ```bash
   # Remove existing TPM token
   sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/nvme0n1p2

   # Re-enroll with Secure Boot and firmware PCRs
   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7 /dev/nvme0n1p2
   ```

______________________________________________________________________

## 🌐 Networking & Mesh Diagnostics

### Tailscale Routing & DNS Issues

```bash
# Verify connection to coordination servers
tailscale status

# Check if MagicDNS is resolving
tailscale ping 100.x.y.z

# Restart the Tailscale daemon
sudo systemctl restart tailscale.service

# Flush and test local DNS cache
sudo resolvectl flush-caches
resolvectl query myhost.apollan.cc
```

### K3s Cluster Quorum Diagnostic

On any Pluto cluster master node (`pluto`, `styx`, `hydra`):

```bash
# Check service health
sudo systemctl status k3s.service

# Verify etcd cluster health
sudo k3s etcd-snapshot list
sudo kubectl get nodes -o wide

# Check K3s supervisor logs
journalctl -u k3s.service -n 100 -f
```
