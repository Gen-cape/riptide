{
  description = "Random cursed TIDE LOAD OF DERIVATIONS";

  outputs = inputs: let
    inherit (inputs) self;
    selfPath = builtins.unsafeDiscardStringContext "${self}";
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      imports = [
        ./packages
        ./lib
        ./test.nix
      ];

      perSystem = {system, ...}: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      };

      flake = {
        templates.default.path = ./templates/vanilla;
        templates.pip.path = ./templates/pythonImpure;
      };
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # nixpkgs.url = "github:nixos/nixpkgs?rev=a225c7d3073fb5bdef090a1b7986d18a8d557b1a";
    # nixpkgs.url = "github:nixos/nixpkgs?rev=5df43628fdf08d642be8ba5b3625a6c70731c19c";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };
}
