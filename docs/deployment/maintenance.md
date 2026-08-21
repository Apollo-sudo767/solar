# Routine Updates & System Maintenance 🔄

Solar provides built-in shortcuts and automation to keep the entire machine fleet updated and healthy.

______________________________________________________________________

## ⚡ Built-in Rebuild Aliases

| Command | Action | Description |
| :--- | :--- | :--- |
| `nrs` | `nh os switch .` | Rebuilds and activates Linux configuration immediately via `nh`. |
| `nrb` | `nh os boot .` | Rebuilds configuration and sets as default for next boot. |
| `drs` | `nh darwin switch .` | Rebuilds and switches macOS system environment (`phobos`). |
| `nfu` | `nix flake update` | Updates all flake inputs in `flake.lock`. |
| `nfc` | `nix flake check` | Validates and checks flake evaluation. |
| `seed` | Bitwarden Age unlock | Unlocks and seeds master encryption key into volatile RAM (`/run/user/...`). |
| `unseed` | Purge RAM key | Securely purges the master Age key from RAM. |

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
