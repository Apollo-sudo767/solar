# Contributing to Solar 🤝

Thank you for your interest in contributing to **Solar**! Solar is designed as a clean, automated, and dendritic NixOS & macOS configuration.

______________________________________________________________________

## 🌐 Single Source of Truth: GitHub Pages Only

To prevent fragmented navigation, broken links, and out-of-sync documentation across separate wiki systems, **all Solar documentation is unified exclusively through mdBook and deployed to GitHub Pages**:

- 📖 **Official Documentation Hub**: [https://apollo-sudo767.github.io/solar/](https://apollo-sudo767.github.io/solar/)
- 📁 **Documentation Source**: All book sources live directly inside the [`docs/`](file:///Users/apollo/src/solar/docs) directory of the main Git repository.
- 🚀 **Automated CI/CD**: Every commit pushed to `main` triggers `.github/workflows/docs.yml`, which automatically rebuilds mdBook and updates GitHub Pages in real-time.
- 🚫 **No Separate GitHub Wiki**: We intentionally do not use GitHub's separate repository Wiki tab so that all code and documentation remain version-controlled, peer-reviewed via Pull Requests, and navigable in a single unified interface.

### Previewing Documentation Locally

You can test and preview the mdBook documentation live with hot-reloading using Nix:

```bash
# Serve the documentation locally on http://localhost:3000
nix run nixpkgs#mdbook -- serve --open
```

Or build the static HTML book:

```bash
nix run nixpkgs#mdbook -- build
```

______________________________________________________________________

## 🌲 Core Architectural Principles

When submitting code to Solar, all modules and hosts must adhere to the **Dendritic Principles**:

### 1. Unified Namespace (`myFeatures.*`)
All custom options must be defined under `config.myFeatures.<category>.<subcategory>.<feature>`. Never introduce top-level configuration options outside `myFeatures`.

### 2. The Suite Law (Strict Separation of Concerns)
- **Suites (`modules/suites/`)**: Bundle multi-module workflows and tools (e.g., `suites.workstation`, `suites.gaming`, `suites.creator`, `suites.server`, `suites.desktops.*`) using `lib.mkDefault` on all values.
- **Never Declare Styling or Greeters in Suites**: Themes (`themes.sky`, `themes.forest`, `themes.strawberry`, `themes.space`), Stylix color palettes, wallpapers, and Display Managers (`regreet`, `sddm`, `gdm`, `cosmic-greeter`) are strictly personal machine identities and **must only be declared in the host file** (`modules/hosts/<hostname>/default.nix`).

### 3. Dynamic Module Discovery
- All `.nix` files placed under `modules/` are automatically discovered by `modules/default.nix`.
- Modules that only apply to Linux must **not** include `isDarwin` in their top-level function arguments.
- Modules for macOS must be placed in `modules/darwin/` or include `isDarwin` in their arguments.
- Universal modules intended for both Linux and macOS must include `isTotal` in their arguments.

### 4. Multi-User Generation
Never hardcode a single username. Always generate user configs dynamically across all configured usernames:

```nix
home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (name: {
  # Per-user configuration
});
```

### 5. Impermanence Preservation
Stateful directories for software must declare preservation paths when impermanence is enabled:

```nix
preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
  lib.mkIf (config.myFeatures.core.system.preservation.enable && !isDarwin) {
    users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      directories = [ ".config/my-app" ".local/share/my-app" ];
    });
  };
```

______________________________________________________________________

## 🧪 Testing & Validation Checklist

Before opening a Pull Request, verify that your changes evaluate cleanly across all machines in the constellation:

```bash
# 1. Stage any newly created files so Nix can see them
git add -A

# 2. Test evaluation of Linux hosts (Workstation, Gaming, Server)
nix eval .#nixosConfigurations.mars.config.system.stateVersion
nix eval .#nixosConfigurations.elara.config.system.stateVersion
nix eval .#nixosConfigurations.ganymede.config.system.stateVersion
nix eval .#nixosConfigurations.venus.config.system.stateVersion

# 3. Test evaluation of macOS host
nix eval .#darwinConfigurations.phobos.config.system.stateVersion

# 4. Test building the documentation
nix run nixpkgs#mdbook -- build
```

______________________________________________________________________

## 🔄 Pull Request Workflow

1. **Fork the Repository**: Create a personal fork and clone it locally.
2. **Create a Feature Branch**:
   ```bash
   git checkout -b feat/my-new-feature
   ```
3. **Commit Changes**: Use Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`).
4. **Push and Open a PR**: Push your branch to GitHub and open a Pull Request against `main`. Provide a concise summary of changes and validation test results.
