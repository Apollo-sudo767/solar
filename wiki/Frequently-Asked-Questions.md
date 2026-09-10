# Frequently Asked Questions ❓

Common questions regarding the Solar architecture, design decisions, storage, and platform support.

______________________________________________________________________

## 🌟 General Architecture

### Why use an automated "Dendritic" module tree?

In traditional NixOS flakes, developers manually import lists of Nix files in `imports = [ ... ]`, leading to import drift, circular dependencies, and repetitive boilerplate. Solar's dendritic scanner automatically discovers and imports all feature modules, desktop environments, and platform settings.

### What is the difference between `isDarwin` and `isTotal`?

- **`isDarwin`**: Evaluates `true` when building for macOS (`aarch64-darwin` or `x86_64-darwin`), filtering out Linux-exclusive kernel options, systemd daemons, and Wayland packages.
- **`isTotal`**: Controls full vs. minimal system feature sets, allowing lightweight deployment on testbeds or resource-constrained nodes.

______________________________________________________________________

## 💾 Storage & Preservation

### How does wipe-on-boot root (`tmpfs`) work without data loss?

Solar mounts the root filesystem `/` entirely in RAM (`tmpfs`). When the computer powers down or reboots, RAM clears and the root filesystem resets to a pristine state. Persistent directories (SSH keys, system state, logs, Home directories, Docker/K3s runtime data) are explicitly bound to `/persist` and `/persist/bulk` on physical NVMe/HDD partitions using `preservation` and `impermanence`.

### What happens if I forget to persist a file or directory?

Any files created outside of `/persist`, `/nix`, or `/persist/bulk` will disappear upon reboot. To permanently keep files:

1. Add the path to `myFeatures.storage.preservation.preserveDirectories` in your host or suite configuration.
1. Rebuild the system (`nh os switch .`).

______________________________________________________________________

## 🔐 Secrets & Security

### Can I build Solar without access to private secrets?

Yes! Solar adheres to a **Zero-Secret Bootstrap** architecture. Standalone hosts and development environments evaluate and boot without requiring access to private secret flakes. Hosts requiring credentials (e.g. WiFi passphrases, VPN configs, or K3s join tokens) seamlessly load encrypted Age files via `agenix-rekey` when private master keys are present.

### How are secrets injected into the Pluto K3s Cluster?

No secret manifests or plaintext tokens are checked into Git. Instead, NixOS on `pluto` runs `k3s-secrets-sync.service` on boot. It reads the local decrypted Agenix secrets and creates or updates native Kubernetes Secrets in their respective namespaces using `kubectl`.

______________________________________________________________________

## 🍎 macOS & Darwin Support

### Can I use the same flake for both Linux and macOS?

Yes! Host `phobos` is an Apple Silicon MacBook running `nix-darwin` with Homebrew integration, Raycast, and macOS system preferences, managed entirely from this unified flake repository.
