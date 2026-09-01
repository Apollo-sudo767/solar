# Welcome to the Solar Wiki ☀️

**Solar** is a hybrid NixOS and macOS configuration structured as an automated, dendritic flake. It manages a fleet of personal workstations, portable laptops, handheld gaming devices, high-performance servers, dedicated NAS nodes, and general storage pools from a single unified repository.

______________________________________________________________________

## 🌟 Quick Links

- 🌲 **[Architecture](Architecture.md)**: Deep dive into the Dendritic Tree and automatic module discovery.
- 📜 **[Definitive Toggle Reference](Definitive-Toggle-List.md)**: Complete catalog of all 532 flake configuration options and toggles.
- ⚙️ **[How Modules Work](How-Modules-Work.md)**: Comprehensive guide to options, multi-user Home Manager, and styling.
- 🖥️ **[Setting Up a Basic Desktop](Setting-Up-a-Basic-Desktop.md)**: Blueprint for configuring a workstation or laptop.
- 🖧 **[Setting Up a Basic Server](Setting-Up-a-Basic-Server.md)**: Blueprint for configuring a headless storage or application server.
- 🪐 **[Fleet Overview](Fleet-Overview.md)**: Detailed breakdown of all machines in the Solar constellation.
- 🚀 **[Installation & Deployment](Installation-&-Deployment.md)**: Bare-metal setup, interactive `install.sh`, and `nixos-anywhere`.
- 💾 **[Storage & Disko](Storage-&-Disko.md)**: Universal hardware-aware Disko, Btrfs subvolumes, and drive swapping.
- 🛡️ **[Security & Hardening](Security-&-Hardening.md)**: LUKS encryption, Limine Secure Boot, and TPM 2.0 auto-unlock.
- 🍼 **[Adding a New Host](Adding-a-New-Host.md)**: Blueprint guide for spinning up new configurations.
- 🧩 **[Adding a New Feature](Adding-a-New-Feature.md)**: Creating reusable modular feature branches.

______________________________________________________________________

## 🎯 Design Philosophy

1. **Dendritic & Modular**: No massive monolithic files. Features and host configurations are small, self-contained terminal leaves that the system scans and attaches dynamically.
1. **Universal Hardware Awareness**: A single Disko storage engine intelligently provisions single-disk, multi-disk speed pools, or bulk storage pools without writing custom partition layouts for each machine.
1. **Defense in Depth**: Zero-compromise security defaults including AppArmor MAC profiles, kernel hardening, memory checking, LUKS disk encryption, Limine Secure Boot signing, and TPM 2.0 hardware binding.
1. **Declarative & Reproducible**: Fully managed with pure Nix flakes, NixOS, and `nix-darwin`.
