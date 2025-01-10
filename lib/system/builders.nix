{
  lib,
  mimics,
  ...
}: let
  inherit (lib.attrsets) recursiveUpdate;
  inherit (lib.modules) mkDefault;
  inherit (mimics) dropFunctor;
  mergeSets = {
    __functor = self: arg:
      if arg != null
      then recursiveUpdate self arg
      else dropFunctor self;
  };

  systemEssence = withSystem: system:
    withSystem system ({
      inputs',
      self',
      pkgs,
      system,
      ...
    }: {
      inherit inputs' self' pkgs system;
    });

  mkSystem = {
    withSystem,
    basicArgs ? {},
    ...
  }: {
    hostname,
    system ? "x86_64-linux",
    modules ? [],
    specialArgs ? {},
    ...
  } @ otherArgs: let
    essence = systemEssence withSystem system;
    baseModule = {
      networking.hostName = hostname;
      nixpkgs.hostPlatform = mkDefault system;
    };
  in
    lib.nixosSystem {
      inherit system;
      specialArgs =
        mergeSets
        {inherit lib;}
        {inherit (essence) inputs' self' system;}
        basicArgs
        specialArgs
        null;

      modules = lib.flatten ([baseModule] ++ modules);
    };

  mkHome = {
    withSystem,
    homeManagerConfiguration,
    basicArgs ? {},
    ...
  }: {
    username,
    homeDirectory ? "/home/${username}",
    system ? "x86_64-linux",
    modules ? [],
    specialArgs ? {},
    ...
  } @ otherArgs: let
    essence = systemEssence withSystem system;
    baseModule = {
    };
  in
    homeManagerConfiguration {
      # inherit system;
      inherit (essence) pkgs;
      extraSpecialArgs =
        mergeSets
        essence
        basicArgs
        specialArgs
        null;

      modules = lib.flatten ([baseModule] ++ modules);
    };
in {
  inherit mkSystem systemEssence mkHome;
}
