# parts/devshells.nix
{ inputs, ... }:

{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells = {
        # 1. CORE / GENERAL
        default = pkgs.mkShell {
          name = "solar-core";
          packages =
            with pkgs;
            [
              inputs.agenix.packages.${pkgs.system}.default
              age
              age-plugin-yubikey
              ssh-to-age
              nil
              git
              nh
              comma
              nix-index
            ]
            ++ lib.optional pkgs.stdenv.isDarwin age-plugin-se;

          shellHook = ''
            ${config.pre-commit.installationScript}
            echo "☀️ Solar environment active."
          '';

        };

        # 2. PYTHON (Data Science / Scripting)
        python = pkgs.mkShell {
          name = "python-env";
          packages = with pkgs; [
            (python3.withPackages (
              ps: with ps; [
                pandas
                requests
                black
                flake8
                pip
              ]
            ))
          ];
          shellHook = ''echo "🐍 Python environment active"'';
        };

        # 3. RUST (Systems Programming)
        rust = pkgs.mkShell {
          name = "rust-env";
          packages = with pkgs; [
            cargo
            rustc
            rust-analyzer
            clippy
            rustfmt
          ];
          # Set environment variables for Rust
          env = {
            RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
          };
          shellHook = ''echo "🦀 Rust environment active"'';
        };

        # 4. WEB (JavaScript / TypeScript)
        web = pkgs.mkShell {
          name = "web-env";
          packages = with pkgs; [
            nodejs_22
            corepack_22
            typescript-language-server
          ];
          shellHook = ''echo "🌐 Web/JS environment active"'';
        };

        # 5. GO (Cloud Native)
        go = pkgs.mkShell {
          name = "go-env";
          packages = with pkgs; [
            go
            gopls
            go-tools
          ];
          shellHook = ''echo "🐹 Go environment active"'';
        };

        # 6. C/C++ (Low Level)
        cc = pkgs.mkShell {
          name = "cc-env";
          packages = with pkgs; [
            gcc
            gnumake
            cmake
            gdb
            clang-tools
          ];
          shellHook = ''echo "🔨 C/C++ environment active"'';
        };
      };
    };
}
