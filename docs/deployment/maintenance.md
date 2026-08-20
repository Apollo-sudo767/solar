# Routine Updates & System Maintenance 🔄

Solar provides built-in shortcuts and automation to keep the entire machine fleet updated and healthy.

______________________________________________________________________

## ⚡ Built-in Rebuild Aliases

| Command | Action | Description |
| :--- | :--- | :--- |
| `nrs` | `sudo nixos-rebuild switch --flake .` | Rebuilds and activates configuration immediately. |
| `nrb` | `sudo nixos-rebuild boot --flake .` | Rebuilds configuration and sets as default for next boot. |
| `nfu` | `nix flake update` | Updates all flake inputs in `flake.lock`. |
| `drs` | `darwin-rebuild switch --flake .` | Rebuilds and switches macOS system environment (`phobos`). |

______________________________________________________________________

## 🧹 Garbage Collection & Optimization

Solar automatically cleans up older generations on a weekly schedule. To run manual garbage collection and store optimization:

```bash
# Clean generations older than 7 days
sudo nix-collect-garbage --delete-older-than 7d

# Deduplicate identical store files
sudo nix-store --optimize
```

______________________________________________________________________

## 💾 Storage Health & Btrfs Scrubbing

Check Btrfs scrubbing and drive status:

```bash
# Check Btrfs filesystem status
sudo btrfs filesystem show

# Check scrub status on root and bulk pools
sudo btrfs scrub status /
sudo btrfs scrub status /persist/bulk
```
