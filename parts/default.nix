# parts/default.nix
# ============================================================================
# Flake Parts Autoloader
# ============================================================================
# Automatically discovers and imports every `.nix` file inside `parts/`
# (excluding `default.nix` itself to avoid infinite recursion).
#
# Note: `inputs.agenix-rekey.flakeModule` is imported canonically at the top
# level in `flake.nix` so it does not need to be duplicated here.
{ lib, ... }:

{
  imports = builtins.filter (path: builtins.baseNameOf path != "default.nix") (
    lib.filesystem.listFilesRecursive ./.
  );
}
