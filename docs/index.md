# Solar Documentation ☀️

Welcome to the documentation for **Solar** — a hybrid NixOS and macOS configuration structured as an automated, dendritic flake.

![Solar Banner](../assets/wallpapers/limine-bg.png)

______________________________________________________________________

## 🌟 What is Solar?

Solar manages a fleet of personal workstations, portable laptops, handheld gaming devices, high-performance servers, dedicated NAS nodes, and general storage pools from a single unified repository.

### Core Highlights:

- 🌲 **Dendritic Module Architecture**: Self-discovering module graph with automatic platform filtering for macOS and Linux.
- 💾 **Universal Hardware-Aware Disko**: Single declarative storage engine supporting single-disk, multi-disk speed pools, and high-capacity bulk pools with Btrfs.
- 🛡️ **Zero-Compromise Security**: AppArmor MAC profiles, kernel hardening, memory checking, LUKS disk encryption, Limine Secure Boot, and TPM 2.0 hardware binding.
- 🚀 **Zero-Secret Bootstrap**: Standalone hosts run completely self-contained without requiring access to private secret submodules.

______________________________________________________________________

## 🧭 Navigation Guide

Use the sidebar on the left or press <kbd>S</kbd> to search anywhere in this book:

- **[System Architecture](architecture.md)**: Deep dive into the Dendritic Tree and module scanner.
- **[Fleet Overview](fleet/overview.md)**: Detailed breakdown of all machines in the Solar constellation.
- **[Universal Disko](storage/disko.md)**: Storage layout, preservation vs. standard modes, and Btrfs pools.
- **[Security & Cryptography](security/luks.md)**: LUKS encryption, Limine Secure Boot, and TPM2 auto-unlock.
- **[Bare-Metal Installation Guide](deployment/installation.md)**: Step-by-step installation instructions.
