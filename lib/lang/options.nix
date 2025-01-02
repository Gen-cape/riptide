{
  lib,
  mimics,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) bool str isOptionType isType;
  inherit (lib.attrsets) recursiveUpdate;
  inherit (mimics) dropFunctor;

  mkOpt = type: default:
    mkOption {
      inherit type default;
      description = "";
    };

  mkOpt' = {
    __functor = self: arg: let
      hasAllFields = self ? type && self ? description && self ? default;

      finalizer =
        if hasAllFields
        then dropFunctor
        else lib.id;

      updatedSelf =
        if !self ? type && isOptionType arg
        then {type = arg;}
        else if self ? type
        then {default = arg;}
        else {description = arg;};
    in
      finalizer (self // updatedSelf);
  };

  mkStrOpt = default: mkOpt str default;
  mkDisableOpt = name: mkEnableOption name // {default = true;};
in {
  inherit
    mkOpt
    mkOpt'
    mkStrOpt
    mkDisableOpt
    ;
  mopt = mkOpt';
}
