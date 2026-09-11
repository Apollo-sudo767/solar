# Frequently Asked Questions ❓

Common architectural questions and rationale behind Solar's design decisions.

______________________________________________________________________

## 🌲 Architecture & Flake Structure

### Q: Why not keep modules in one flat directory?

A flat directory becomes unmaintainable as configurations scale past 5 machines. Solar’s dendritic tree creates a clear separation between:

- Foundations (`core/`)
- Platform tools (`programs/`, `platforms/`, `services/`)
- Workflow presets (`suites/`)
- Concrete machine declarations (`hosts/`)

### Q: How does automatic module discovery work?

`modules/default.nix` recursively scans `modules/` for `.nix` files and automatically maps them to typed options under `myFeatures.<path>.enable`. You never have to manually import new feature files in `flake.nix`.

______________________________________________________________________

## 💾 Storage & Ephemeral Roots

### Q: What is "wipe-on-boot" (ephemeral root)?

On hosts like **`mars`**, **`mercury`**, and the **Pluto Cluster**, the root filesystem (`/`) is mounted in RAM (`tmpfs`) or wiped on every boot. Only directories explicitly declared in `preservation` (such as `.config`, `.local/share`, `/etc/nixos`, and `/var/log`) survive reboots on the NVMe `/persist` subvolume. This prevents filesystem rot, stale cache buildup, and accidental unmanaged state.

### Q: How do I preserve a new application's state on an ephemeral host?

Declare it in the module's `preservation.preserveAt` list, or place the directory under `/persist/home/apollo/` and symlink it to your home folder.

______________________________________________________________________

## 🍏 macOS Darwin Integration

### Q: How does Solar manage both NixOS and macOS in the same flake?

`flake.nix` exports both `nixosConfigurations` (for Linux hosts) and `darwinConfigurations` (for macOS hosts like **`phobos`**). The module autoscanner (`modules/default.nix`) uses platform reflection to load `modules/darwin/` and modules with `isDarwin` or `isTotal` on macOS while excluding Linux-only kernel and driver modules.

______________________________________________________________________

## 🪐 The Fleet & Pluto Cluster

### Q: Why run K3s as an HA cluster on mini-PCs and laptops?

The Pluto Cluster provides a resilient, zero-single-point-of-failure GitOps platform for self-hosted services (Jellyfin, Home Assistant, Minecraft). By using three heterogeneous physical nodes with an embedded etcd quorum, individual nodes can reboot for system updates without service downtime.

### Q: Why are Ganymede and Callisto deprecated?

Legacy storage nodes `ganymede` and `callisto` were retired in favor of **`sol`** (Central ZFS NAS with multi-terabyte mirrored storage and NFS exports) and dynamic Kubernetes persistent volumes managed by the Pluto Cluster.
