{
  description = "Vanilla project";

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [];
      # systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      systems = ["x86_64-linux"];
      # perSystem = {config,self',inputs',pkgs,system,...}: {
      perSystem = {pkgs, ...}: {
        # packages.default = pkgs.callPackages ./default.nix {}; # or inputs'.nixpkgs.legacyPackages.hello
        devShells.default = pkgs.mkShell rec {
          nativeBuildInputs = [
            (pkgs.writeShellScriptBin "bd" ''nix build'')
          ];
          buildInputs = [];
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
        };
      };
      flake = {};
    };

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
}
