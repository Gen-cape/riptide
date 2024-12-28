{
  description = "Random cursed TIDE LOAD OF DERIVATIONS";

  outputs = inputs: let
    inherit (inputs) self;
    selfPath = builtins.unsafeDiscardStringContext "${self}";
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      perSystem = {
        pkgs,
        system,
        ...
      }: {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            (writeShellScriptBin "bd" ''
              nix build .#default --no-substitute --out-link bd
            '')
            (writeShellScriptBin "rn" ''
              nix run --no-substitute
            '')
            # (pkgs.callPackage ./packages/jujutsu/jujutsu-fzf.nix {})
          ];
        };
        packages = rec {
          sttt = pkgs.callPackage ./packages/sttt/sttt.nix {};
          jujutsu-fzf = pkgs.callPackage ./packages/jujutsu/jujutsu-fzf.nix {};
          fast = pkgs.callPackage ./packages/default.nix {};
          default = fast;
        };

        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      };

      flake = let
        pkgs = inputs.nixpkgs;
        inherit (inputs.nixpkgs) lib;
        mimics = import ./lib {inherit lib pkgs;};
      in {
        inherit mimics;
        templates.default = {
          path = ./templates/vanilla;
        };
      };
    };

  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs.url = "github:nixos/nixpkgs?rev=a225c7d3073fb5bdef090a1b7986d18a8d557b1a";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
}
