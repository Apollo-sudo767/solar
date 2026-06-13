# parts/treefmt.nix
{ inputs, ... }:

{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem = _: {
    treefmt = {
      projectRootFile = "flake.nix";
      programs = {
        nixfmt.enable = true; # Standard Nix formatter
        deadnix.enable = false; # Find unused Nix code
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
