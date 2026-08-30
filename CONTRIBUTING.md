# Contributing to Solar 🤝

Welcome! To keep all documentation in sync and avoid fragmented navigation across multiple wiki platforms, **all Solar documentation and developer guides are hosted exclusively on GitHub Pages**:

👉 **[Read the Full Contributing Guide](https://apollo-sudo767.github.io/solar/contributing.html)**

---

### Quick Contributing Summary

1. **Single Source of Truth**: All documentation is maintained under [`docs/`](docs/) and compiled via mdBook to GitHub Pages.
2. **Dendritic Architecture**: All new modules belong under `modules/<category>/` and must use `myFeatures.<category>.<subcategory>.<feature>`.
3. **The Suite Law**: Suites (`modules/suites/`) bundle functional workflows with `lib.mkDefault`. Styling, themes, and display managers are strictly declared per host.
4. **Validation**: Test host evaluations locally before submitting PRs:
   ```bash
   nix eval .#nixosConfigurations.mars.config.system.stateVersion
   nix eval .#darwinConfigurations.phobos.config.system.stateVersion
   nix run nixpkgs#mdbook -- build
   ```

For comprehensive guidelines, visit the **[Solar Documentation Hub](https://apollo-sudo767.github.io/solar/)**.
