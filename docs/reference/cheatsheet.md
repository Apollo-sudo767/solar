# Universal Cheatsheet ⚡

Quick reference for day-to-day operations, flake management, and system recovery in Solar.

______________________________________________________________________

## 🚀 Rebuild & Maintenance Aliases

Solar includes native shell aliases powered by `nh`:

| Alias | Command | Purpose |
| :--- | :--- | :--- |
| `nrs` | `nh os switch --no-nom` | Build and activate system configuration immediately |
| `nrb` | `nh os boot --no-nom` | Build configuration and register for next boot without switching |
| `drs` | `nh darwin switch --no-nom` | Build and activate macOS Darwin configuration |
| `nfu` | `nix flake update` | Update all flake lock input dependencies |
| `nfc` | `nix flake check` | Evaluate and check flake outputs and assertions |
| `nc` | `nh clean all` | Prune old generations, keeping last 5 within 7 days |
| `nco` | `nh clean all --keep 3 && nix-store --optimise` | Deep store clean and hardlink deduplication |

______________________________________________________________________

## 🔐 Secrets & Agenix Operations

| Operation | Command | Description |
| :--- | :--- | :--- |
| **Seed Keyring** | `solar-seed` (or `seed`) | Decrypt Age master key into RAM keyring |
| **Unseed Keyring**| `solar-unseed` (or `unseed`) | Purge Age master key from RAM |
| **Edit Secret** | `agenix -e secrets/<name>.age` | Decrypts, opens in `$EDITOR`, re-encrypts |
| **Rekey Secrets** | `agenix -r` | Rekey all secrets for all declared host public keys |
| **Inspect Secret**| `cat /run/agenix/<name>` | View live decrypted secret in RAM |

______________________________________________________________________

## 🌐 Network & Tailscale Diagnostics

```bash
# Check tailnet status and ping mesh nodes
tailscale status
tailscale ping <hostname>

# Force SSH key-only reauthentication
sudo tailscale up --ssh --operator=apollo

# Flush DNS caches
resolvectl flush-caches
sudo systemctl restart systemd-resolved
```

______________________________________________________________________

## 💾 Storage & Btrfs Health

```bash
# Check filesystem space & allocation
sudo btrfs filesystem usage /

# Trigger manual maintenance scrub
sudo btrfs scrub start /
sudo btrfs scrub status /

# Check ZFS storage pool health (on Sol)
zpool status -v
zfs list
```
