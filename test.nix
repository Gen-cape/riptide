{
  self,
  withSystem,
  ...
}:
with self.mimics; {
  flake.outRes = systemEssence withSystem "x86_64-linux";
}
