# Terminal & Developer Tools 💻

Solar provides a fast, GPU-accelerated terminal environment paired with modern developer tools, editors, and AI coding assistants.

______________________________________________________________________

## 🛠️ Included Developer Toolchain

| Tool | Option Path | Description |
| :--- | :--- | :--- |
| **Ghostty** | `myFeatures.programs.terminal.ghostty` | High-performance, GPU-accelerated terminal emulator with Wayland fractional scaling. |
| **Helix** | `myFeatures.programs.terminal.helix` | Post-modern modal text editor with built-in LSP support, tree-sitter, and multiple selections. |
| **Antigravity CLI** | `myFeatures.programs.terminal.antigravity` | Agentic AI pair programming assistant by Google DeepMind. |
| **NH (Nix Helper)** | `myFeatures.programs.terminal.nh` | Clean CLI rebuild helper (`nrs`, `drs`, `nh clean`) with target flake path resolution. |
| **Fastfetch** | `myFeatures.programs.terminal.fastfetch` | Fast, aesthetic system information fetch tool with Solar branding. |
| **Direnv** | `myFeatures.programs.terminal.direnv` | Shell extension for per-directory environment variable loading and Nix `nix-direnv` shells. |
| **Nix-LD** | `myFeatures.programs.terminal.nix-ld` | System-wide compatibility layer allowing unpatched dynamic Linux binaries to run out of the box. |
| **Git** | `myFeatures.programs.terminal.git` | Declarative Git configuration with automated commit signing, user names, and aliases. |

______________________________________________________________________

## ⚡ Daily Rebuild Shortcuts

Integrated Zsh aliases available across all Solar hosts:

```bash
nrs     # nh os switch .        (Rebuild and activate Linux OS)
nrb     # nh os boot .          (Rebuild and set as default for next boot)
drs     # nh darwin switch .    (Rebuild macOS environment on Phobos)
nfu     # nix flake update      (Update pinned dependencies)
nc      # nh clean all          (Clean older generations)
```
