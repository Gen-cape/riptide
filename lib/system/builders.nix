{
  lib,
  mimics,
  ...
}: let
  inherit (lib.attrsets) recursiveUpdate getAttrs;
  inherit (lib.modules) mkDefault;
  inherit (lib.lists) flatten;
  inherit (mimics) dropFunctor;

  # mergeSets :: AttrSet -> AttrSet? -> AttrSet
  mergeSets = {
    __functor = self: arg:
      if arg != null
      then recursiveUpdate self arg
      else dropFunctor self;
  };

  # systemEssence :: (System -> (AttrSet -> Essence)) -> System -> Essence
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

  # select :: [String]? -> AttrSet -> AttrSet
  select = attrs: set:
    if attrs != null
    then getAttrs attrs set
    else set;

  # apply :: (a -> b)? -> a -> a|b
  apply = f: x:
    if f != null
    then f x
    else x;

  # extractWithDefaults :: [String] -> AttrSet -> AttrSet -> AttrSet
  # Extract attributes with default values for missing ones
  extractWithDefaults = attrs: defaults: source:
    lib.genAttrs attrs (
      name:
        if source ? ${name}
        then source.${name}
        else defaults.${name} or null
    );

  # Module filtering utilities
  moduleTools = {
    # filter :: (Module -> Bool) -> [Module] -> [Module]
    filter = pred: modules: builtins.filter pred (flatten modules);

    # exclude :: [String] -> [Module] -> [Module]
    exclude = names:
      moduleTools.filter (
        m:
          !(builtins.isAttrs m && m ? moduleName && builtins.elem m.moduleName names)
      );

    # include :: [String] -> [Module] -> [Module]
    include = names:
      moduleTools.filter (
        m:
          !(builtins.isAttrs m && m ? moduleName) || builtins.elem m.moduleName names
      );
  };

  # mkConfiguration :: {args} -> UserArgs -> Result
  mkConfiguration = {
    withSystem, # withSystem :: System -> (AttrSet -> Essence)
    configFunction, # configFunction :: ConfigArgs -> Result
    basicArgs ? {}, # basicArgs :: AttrSet
    makeBaseModule ? _: {}, # makeBaseModule :: UserArgs -> Module
    makeExtraArgs ? (_: _: {}), # makeExtraArgs :: UserArgs -> Essence -> AttrSet
    specialArgsKey ? "specialArgs", # specialArgsKey :: String
    include ? {
      essence = null; # Attributes to include from system essence
      basicArgs = null; # Attributes to include from basicArgs
    }, # include :: { essence :: [String]?, basicArgs :: [String]? }
    moduleFilter ? null, # moduleFilter :: ([Module] -> [Module])?
    # General attribute passing mechanism
    pass ? {
      attrs = []; # Attributes to extract from args to specialArgs
      defaults = {}; # Default values (defaults to null if not specified)
    }, # pass :: { attrs :: [String], defaults :: AttrSet }
  }: args: let
    system = args.system or "x86_64-linux";

    # Get essence and filter
    fullEssence = systemEssence withSystem system;
    filteredEssence = select include.essence fullEssence;

    # Filter basicArgs
    filteredBasicArgs = select include.basicArgs basicArgs;

    # Process modules
    baseModule = makeBaseModule args;
    allModules = flatten ([baseModule] ++ (args.modules or []));
    filteredModules = apply moduleFilter allModules;

    # Extract attributes with defaults
    extractedAttrs = extractWithDefaults pass.attrs pass.defaults args;

    # Merge special arguments (extracted attrs override specialArgs)
    mergedSpecialArgs =
      mergeSets
      filteredEssence
      filteredBasicArgs
      (args.specialArgs or {})
      extractedAttrs # These take precedence over user-provided specialArgs
      
      null;

    # Build function arguments
    functionArgs =
      {
        ${specialArgsKey} = mergedSpecialArgs;
        modules = filteredModules;
      }
      // makeExtraArgs args fullEssence;
  in
    configFunction functionArgs;

  # mkSystem :: { ... } -> { hostname :: String?, ... } -> NixOSConfig
  mkSystem = {
    withSystem, # withSystem :: System -> (AttrSet -> Essence)
    nixosSystem, #  nixosSystem :: NixOSArgs -> NixOSConfig
    basicArgs ? {}, #  basicArgs :: AttrSet
    include ? {
      #  basicArgs :: [String]? } #  include :: { essence :: [String]?,
      essence = ["inputs'" "self'" "system"];
      basicArgs = null;
    },
    moduleFilter ? null, #  moduleFilter :: ([Module] -> [Module])?
    # Default to passing hostname with null default
    pass ? {
      attrs = ["hostname"];
      defaults = {};
    }, # pass :: { attrs :: [String], defaults :: AttrSet }
    ...
  }:
    mkConfiguration {
      inherit withSystem basicArgs moduleFilter;
      inherit include pass;
      configFunction = nixosSystem;
      makeBaseModule = args: {
        networking.hostName = args.hostname or (pass.defaults.hostname or null);
        nixpkgs.hostPlatform = mkDefault (args.system or "x86_64-linux");
      };
      makeExtraArgs = args: _: {
        system = args.system or "x86_64-linux";
        inherit lib;
      };
    };

  # mkHome :: {...} -> { username :: String, hostname :: String?, ... } -> HomeManagerConfig
  mkHome = {
    withSystem, # withSystem :: System -> (AttrSet -> Essence)
    homeManagerConfiguration, # homeManagerConfiguration :: HomeManagerArgs -> HomeManagerConfig
    basicArgs ? {}, # basicArgs :: AttrSet
    include ? {
      essence = null;
      basicArgs = null;
    }, # include :: { essence :: [String]?, basicArgs :: [String]? }
    moduleFilter ? null, # moduleFilter :: ([Module] -> [Module])?
    # Default to passing username and hostname
    pass ? {
      attrs = ["username" "hostname"];
      defaults = {};
    }, # pass :: { attrs :: [String], defaults :: AttrSet }
    ...
  }: args:
    mkConfiguration {
      inherit withSystem basicArgs moduleFilter;
      inherit include pass;
      configFunction = homeManagerConfiguration;
      specialArgsKey = "extraSpecialArgs";
      makeBaseModule = _: {};
      makeExtraArgs = _: essence: {pkgs = essence.pkgs;};
    }
    args;
in {
  inherit mkSystem mkHome systemEssence;

  # Module filtering utilities
  modules = {
    inherit (moduleTools) filter exclude include;
  };
}
