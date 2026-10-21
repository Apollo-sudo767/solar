# modules/default.nix
# ============================================================================
# Dendritic Module Autoscanner & Platform Router
# ============================================================================
# This file is the heart of the Dendritic architecture. Instead of maintaining
# manual `imports = [ ... ];` lists in every subfolder, `getNixFiles` walks the
# `modules/` directory tree recursively and decides which `.nix` files to import
# for the target host platform (`isDarwin` = true for macOS, false for Linux).
#
# How Platform Filtering Works:
# 1. On Linux (`!isDarwin`):
#    Every `.nix` file under `modules/` (except `modules/hosts/` and
#    `modules/darwin/`) is imported.
# 2. On macOS (`isDarwin`):
#    Because `nix-darwin` does not define Linux-specific NixOS options (like
#    `boot.*`, `systemd.*`, `services.xserver.*`), importing unguarded Linux
#    modules on macOS would fail evaluation. Therefore, a module is imported on
#    macOS ONLY if:
#    - It lives inside `modules/darwin/`, OR
#    - Its top-level function signature explicitly declares `isDarwin` or `isTotal`
#      (signaling that the module is cross-platform and guards any Linux-only
#      attributes with `lib.optionalAttrs (!isDarwin)`), AND
#    - It is not in `displayManager/` (Linux-only login greeters).
{
  lib,
  isDarwin,
  ...
}:

let
  getNixFiles =
    dir:
    let
      contents = builtins.readDir dir;
    in
    lib.flatten (
      lib.mapAttrsToList (
        name: type:
        let
          path = "${toString dir}/${name}";
        in
        if type == "directory" then
          # Skip `modules/hosts/` because host configurations are entrypoints
          # evaluated by `modules/hosts/default.nix`, not shared feature modules.
          if name == "hosts" then [ ] else getNixFiles path
        else if type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix" then
          let
            # Step 1: Import the Nix expression so we can inspect its function arguments
            imported = import path;

            # Step 2: Safely extract top-level formal arguments (`{ config, lib, isDarwin, ... }:`)
            args = if builtins.isFunction imported then builtins.functionArgs imported else { };

            # Step 3: Check whether the module opts into cross-platform evaluation
            hasDarwin = args ? isDarwin;
            hasTotal = args ? isTotal;

            # Step 4: Check directory path constraints
            isInDarwin = lib.hasInfix "/modules/darwin/" (toString path);
            isInDisplayManager = lib.hasInfix "/displayManager/" (toString path);

            # Step 5: Decide whether this file belongs in the host's module evaluation
            shouldImport =
              if isDarwin then (isInDarwin || hasDarwin || hasTotal) && !isInDisplayManager else !isInDarwin;
          in
          if shouldImport then path else [ ]
        else
          [ ]
      ) contents
    );
in
{
  imports = getNixFiles ./.;
}
