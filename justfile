# justfile
set shell := ["bash", "-uc"]

# Show available commands
default:
    @just --list

# Update flake inputs
update:
    nix flake update

# Format all files
fmt:
    nix fmt

# Build a host (Linux)
build-nixos host:
    nixos-rebuild build --flake .#{{host}}

# Switch to a host (Linux)
switch-nixos host:
    sudo nixos-rebuild switch --flake .#{{host}}

# Switch to a host (macOS)
switch-darwin host:
    darwin-rebuild switch --flake .#{{host}}

# Clean up old generations
gc:
    nh clean all --keep 5

# Run pre-commit checks manually
check:
    nix flake check
