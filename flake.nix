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
      ];

      perSystem = {system, ...}: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      };

      flake = {
        lib = import ./lib;
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
