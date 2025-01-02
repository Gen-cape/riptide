{lib, ...}: let
  inherit (lib.attrsets) recursiveUpdate;
  inherit (lib.lists) singleton concatLists;
  inherit (lib.modules) mkDefault;

  mkNixos = lib.nixosSystem;
  mkSystem = {
    withSystem,
    self,
    inputs,
    outPath, #nixpkgs.outPath
    ...
  }: {
    system,
    hostname,
    modules ? [],
    specialArgs ? {},
    ...
  } @ otherArgs: let
    baseModule = {
      networking.hostName = otherArgs.hostname;
      nixpkgs = {
        hostPlatform = mkDefault otherArgs.system;
        flake.source = outPath;
      };
    };
  in
    withSystem system ({
      inputs',
      self',
      ...
    }:
      mkNixos {
        specialArgs =
          recursiveUpdate {
            inherit lib inputs self inputs' self';
          }
          specialArgs;

        modules = concatLists [
          (singleton baseModule)
          modules
        ];
      });
in {
  inherit mkSystem mkNixos;
}
