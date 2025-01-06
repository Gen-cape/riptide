{
  description = "Vanilla python impure project";

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      perSystem = {pkgs, ...}: {
        devShells.default = pkgs.mkShell rec {
          nativeBuildInputs = []; # (pkgs.writeShellScriptBin "" '''')
          buildInputs = [
            pkgs.python3Packages.python
            pkgs.python3Packages.venvShellHook
            pkgs.python3Packages.requests

            pkgs.taglib
            pkgs.openssl
            pkgs.git
            pkgs.libxml2
            pkgs.libxslt
            pkgs.libzip
            pkgs.zlib
          ];
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;

          name = "impurePythonEnv";
          venvDir = "./.venv";

          postVenvCreation = ''
            unset SOURCE_DATE_EPOCH
            pip install -r requirements.txt
          '';

          postShellHook = ''unset SOURCE_DATE_EPOCH'';
        };
      };
    };

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
}
