{ pkgs ? import <nixpkgs> { } }:
{
  # for nix-update
  jj-fzf = pkgs.callPackage ./packages/jj-fzf/default.nix { };
}
