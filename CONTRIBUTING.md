# Contributing to Solar 🤝

Welcome! To keep all documentation in sync and avoid fragmented navigation across multiple wiki platforms, **all Solar documentation and developer guides are hosted exclusively on GitHub Pages**:

👉 **[Read the Full Contributing Guide](https://apollo-sudo767.github.io/solar/contributing.html)**

______________________________________________________________________

### Quick Contributing Summary

1. **Single Source of Truth**: All documentation is maintained in the [`solar-docs`](https://github.com/Apollo-sudo767/solar-docs) repository and compiled via VitePress to GitHub Pages.
1. **Dendritic Architecture**: All new modules belong under `modules/<category>/` and must use `myFeatures.<category>.<subcategory>.<feature>`.
1. **The Suite Law**: Suites (`modules/suites/`) bundle functional workflows with `lib.mkDefault`. Styling, themes, and display managers are strictly declared per host.
1. **Validation**: Test host evaluations locally before submitting PRs (documentation changes should be submitted to [`solar-docs`](https://github.com/Apollo-sudo767/solar-docs)):
   ```bash
   nix eval .#nixosConfigurations.mars.config.system.stateVersion
   nix eval .#darwinConfigurations.phobos.config.system.stateVersion
   ```

For comprehensive guidelines, visit the **[Solar Documentation Hub](https://apollo-sudo767.github.io/solar/)**.
