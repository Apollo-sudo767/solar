# parts/devshells.nix
{ ... }:

{
  perSystem = { pkgs, ... }: {
    devShells = {
      # 1. CORE / GENERAL
      default = pkgs.mkShell {
        name = "solar-core";
        packages = with pkgs; [ sops age nil git nh ];
      };

      # 2. PYTHON (Data Science / Scripting)
      python = pkgs.mkShell {
        name = "python-env";
        packages = with pkgs; [
          (python3.withPackages (ps: with ps; [ 
            pandas requests black flake8 pip 
          ]))
        ];
        shellHook = ''echo "🐍 Python environment active"'';
      };

      # 3. RUST (Systems Programming)
      rust = pkgs.mkShell {
        name = "rust-env";
        packages = with pkgs; [
          cargo rustc rust-analyzer clippy rustfmt
        ];
        # Set environment variables for Rust
        env = { RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}"; };
        shellHook = ''echo "🦀 Rust environment active"'';
      };

      # 4. WEB (JavaScript / TypeScript)
      web = pkgs.mkShell {
        name = "web-env";
        packages = with pkgs; [
          nodejs_20 corepack_20 typescript-language-server
        ];
        shellHook = ''echo "🌐 Web/JS environment active"'';
      };

      # 5. GO (Cloud Native)
      go = pkgs.mkShell {
        name = "go-env";
        packages = with pkgs; [ go gopls go-tools ];
        shellHook = ''echo "🐹 Go environment active"'';
      };

      # 6. C/C++ (Low Level)
      cc = pkgs.mkShell {
        name = "cc-env";
        packages = with pkgs; [
          gcc gnumake cmake gdb clang-tools
        ];
        shellHook = ''echo "🔨 C/C++ environment active"'';
      };
    };
  };
}
