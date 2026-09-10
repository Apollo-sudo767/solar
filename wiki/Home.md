# Welcome to the Solar Wiki ☀️

**Solar** is a hybrid NixOS and macOS configuration structured as an automated, dendritic flake. It orchestrates a constellation of personal workstations, portable laptops, handheld gaming devices, High-Availability Kubernetes clusters, central ZFS storage pools, and cloud services from a single unified repository.

______________________________________________________________________

## 🌟 Quick Links & Navigation Hub

### 📖 Core Architecture & Flake Design

- 🌲 **[Architecture Overview](Architecture.md)**: Deep dive into the Dendritic Tree and automatic module discovery.
- ⚙️ **[How Modules Work](How-Modules-Work.md)**: Comprehensive guide to options, multi-user Home Manager, and styling.
- 🎛️ **[Definitive Toggle Reference](Definitive-Toggle-List.md)**: Complete catalog of all flake configuration options and toggles.

### 🪐 The Fleet & Clusters

- 🗺️ **[Fleet Overview](Fleet-Overview.md)**: Detailed breakdown of all 15 machines in the Solar constellation.
- 🪐 **[The Pluto Cluster](Pluto-Cluster.md)**: 3-node HA Kubernetes (K3s) GitOps cluster (`pluto`, `styx`, `hydra`, `sol`).
- 🖧 **[Setting Up a Basic Server](Setting-Up-a-Basic-Server.md)**: Blueprint for configuring headless servers and storage nodes.
- 🖥️ **[Setting Up a Basic Desktop](Setting-Up-a-Basic-Desktop.md)**: Blueprint for configuring a workstation or laptop.

### ⚡ Cheatsheets & Operations

- ⚡ **[Quick Reference & Cheatsheet](Quick-Reference-&-Cheatsheet.md)**: Day-to-day commands, updates, rollbacks, and secrets.
- ⌨️ **[Universal Keybindings](Universal-Keybindings.md)**: Complete keybinding reference for Niri, Ghostty, Zellij, and Helix.
- 🔧 **[Troubleshooting & Diagnostics](Troubleshooting-&-Diagnostics.md)**: Diagnostic commands, triage trees, and common fixes.
- ❓ **[Frequently Asked Questions](Frequently-Asked-Questions.md)**: Answers to common architectural and operational questions.

### 💾 Storage, Security & Deployment

- 💾 **[Storage & Disko](Storage-&-Disko.md)**: Universal hardware-aware Disko, ZFS pools, Btrfs subvolumes, and drive swapping.
- 🛡️ **[Security & Hardening](Security-&-Hardening.md)**: LUKS encryption, Limine Secure Boot, and TPM 2.0 auto-unlock.
- 🚀 **[Installation & Deployment](Installation-&-Deployment.md)**: Bare-metal setup, interactive `install.sh`, and `nixos-anywhere`.
- 🍼 **[Adding a New Host](Adding-a-New-Host.md)**: Blueprint guide for spinning up new configurations.
- 🧩 **[Adding a New Feature](Adding-a-New-Feature.md)**: Creating reusable modular feature branches.

______________________________________________________________________

## 🎯 Design Philosophy

1. **Dendritic & Modular**: No massive monolithic files. Features and host configurations are small, self-contained terminal leaves that the system scans and attaches dynamically.
1. **Universal Hardware Awareness**: A single Disko storage engine intelligently provisions single-disk, multi-disk speed pools, bulk storage pools, or ephemeral tmpfs roots without writing custom partition layouts for each machine.
1. **Defense in Depth**: Zero-compromise security defaults including AppArmor MAC profiles, kernel hardening, memory checking, LUKS disk encryption, Limine Secure Boot signing, and TPM 2.0 hardware binding.
1. **Declarative & Reproducible**: Fully managed with pure Nix flakes, NixOS, and `nix-darwin`.
