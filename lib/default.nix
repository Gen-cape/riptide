{
  inputs,
  system,
  withSystem,
  ...
} @ pargs: let
  inherit (inputs.nixpkgs) lib;

  inherit
    (import ./callers.nix {
      mimics = customLib;
      inherit lib;
    })
    callWith
    fzf
    wrench
    ;

  callSelf = caller: self:
    caller (lib.recursiveUpdate pargs {
      inherit lib;
      mimics = self;
    });

  # The components of lib that are needed to build the lib as a whole
  # Define manual volumes and so here
  baseLib = lib.makeExtensible (
    self: let
      removeExtension = filename: let
        parts = builtins.split "\\." filename;
        # Get all elements except the last one
        nameParts = builtins.elemAt parts 0;
      in
        if builtins.length parts == 1
        then filename
        else nameParts;
      mergeListOfAttrs = lib.foldl' (exp: acc: lib.recursiveUpdate exp acc) {};
      call = callSelf callWith customLib;
      callLibs = nixFiles: mergeListOfAttrs (map (m: {"${removeExtension (builtins.baseNameOf m)}" = call m;}) nixFiles);
    in
      {
        # manual imports
        xdgTemplate = ./system/xdgTemplate.nix; # yeah, intentionally not called
      }
      // callLibs (fzf ./system "!xdg")
      // callLibs (fzf ./lang "")
      // callLibs (fzf ./external "")
      // {inherit (self.tools) callWith;}
  );

  # Autoparsed bulk of the modules
  coreLib = lib.makeExtensible (self: let
    call = callSelf baseLib.callWith customLib;
  in
    wrench [
      (map call)
      (lib.foldl' (exp: acc: lib.recursiveUpdate exp acc) {})
    ] (fzf ./. "!default.nix !old !debug !__ !external"));

  # Merged result into a single lib
  customLib = baseLib.extend (lib.composeManyExtensions [
    (_: _: coreLib)
  ]);

  wrapPypi =
    withSystem system
    (
      {pkgs, ...}: pkgs.callPackage ./drvs/wrapPypi.nix {}
    );
in {flake.mimics = customLib;}
