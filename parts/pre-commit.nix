# parts/pre-commit.nix
# ============================================================================
# Git Pre-Commit Hooks (`pre-commit-hooks.nix`)
# ============================================================================
# Automatically runs `treefmt` (formatting & static analysis) before each
# commit and during `nix flake check`. Installed into `.git/hooks/pre-commit`
# when entering the default devShell.
{ inputs, ... }:

{
  imports = [ inputs.pre-commit-hooks.flakeModule ];

  perSystem = _: {
    pre-commit = {
      check.enable = true;
      settings.hooks = {
        treefmt.enable = true;
      };
    };
  };
}
