# Quick Reference & Cheatsheet ⚡

A concise cheatsheet of essential commands, flake operations, and system maintenance tasks in Solar.

______________________________________________________________________

## 🚀 System Rebuilds & Updates

| Task | Command | Notes |
| :--- | :--- | :--- |
| **Rebuild Current Host** | `nh os switch .` | Automatically detects local hostname |
| **Rebuild Specific Host** | `nh os switch . -H mars` | Target specific Linux host |
| **Rebuild macOS Host** | `darwin-rebuild switch --flake .#phobos` | Target macOS machine |
| **Test Evaluation Only** | `nix eval .#nixosConfigurations.<host>.config.system.stateVersion` | Instant syntax & module check |
| **Update All Flake Inputs**| `nix flake update` | Updates `flake.lock` |
| **Update Single Input** | `nix flake lock --update-input nixpkgs` | Target specific flake input |
| **System Garbage Collection** | `nh clean all --keep 5` | Keeps latest 5 generations |

______________________________________________________________________

## 💾 Storage & Preservation Commands

| Task | Command | Description |
| :--- | :--- | :--- |
| **Btrfs Filesystem Usage** | `btrfs filesystem usage /` | Detailed allocation breakdown |
| **Trigger Btrfs Scrub** | `sudo btrfs scrub start /persist` | Background data integrity verify |
| **Check Scrub Status** | `sudo btrfs scrub status /persist` | View scrub progress & errors |
| **List Preservation Mounts** | `findmnt -t btrfs` | Show active Btrfs subvolumes |
| **Inspect LUKS Keyslots** | `sudo cryptsetup luksDump /dev/nvme0n1p2` | View enrolled keys & TPM bindings |

______________________________________________________________________

## 🌐 Networking & Diagnostics

| Task | Command | Description |
| :--- | :--- | :--- |
| **Check Tailscale Status** | `tailscale status` | View active mesh peers & IPs |
| **Ping Tailscale Peer** | `tailscale ping <hostname>` | Test WireGuard tunnel latency |
| **Systemd-Resolved Status** | `resolvectl status` | View active DNS servers & cache |
| **Inspect Open Ports** | `ss -tulpn` | List active listening sockets |
| **View Service Logs** | `journalctl -u <service> -f` | Follow live systemd service logs |

______________________________________________________________________

## 🔐 Secrets & Agenix

| Task | Command | Description |
| :--- | :--- | :--- |
| **Edit Secret File** | `agenix -e secrets/<name>.age` | Decrypts, opens in `$EDITOR`, re-encrypts |
| **Rekey All Secrets** | `agenix -r` | Rekey secrets for all host public keys |
| **Check Decrypted Secret** | `cat /run/agenix/<name>` | View live decrypted secret in RAM |
