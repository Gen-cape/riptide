{
  system,
  withSystem,
  ...
}: {
  wrapPypi =
    withSystem system
    (
      {pkgs, ...}: pkgs.callPackage ./wrapPypi.nix {}
    );
}
