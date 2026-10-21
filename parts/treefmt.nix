# parts/treefmt.nix
# ============================================================================
# Unified Code Formatting & Linting (`nix fmt`)
# ============================================================================
# Configures `treefmt-nix` so running `nix fmt` formats and lints the entire
# repository (Nix, Markdown, and Python files) in a single pass.
{ inputs, ... }:

{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem = _: {
    treefmt = {
      projectRootFile = "flake.nix";
      programs = {
        nixfmt.enable = true; # Official RFC 166 Nix formatter
        deadnix.enable = false; # Unused Nix code detector
        statix.enable = true; # Nix anti-pattern linter

        mdformat.enable = true; # Markdown formatter
        black.enable = true; # Python formatter
      };

      settings.formatter = {
        nixfmt.includes = [ "*.nix" ];
        statix.includes = [ "*.nix" ];
      };
    };
  };
}
