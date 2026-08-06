# Antigravity Contribution Rules

## Mandatory Pull Request Policy
All modifications, feature additions, refactors, and bug fixes generated or applied by Antigravity **MUST** be performed on a dedicated git feature branch and submitted as a GitHub Pull Request (PR). Direct pushes or commits to the `main` branch by Antigravity are strictly prohibited.

### Execution Workflow:
1. **Branching**: Always create a feature branch (`feature/<descriptive-name>`).
2. **Verification**: Validate code, configuration syntax (`nix flake check` / `nix eval`), and functionality before committing.
3. **Commit & Push**: Commit changes with concise, descriptive commit messages and push the feature branch to `origin`.
4. **Pull Request**: Open a GitHub Pull Request against `main` for code review.
