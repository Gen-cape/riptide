{pkgs ? import <nixpkgs> {}}: {
  # for nix-update
  jj-fzf = pkgs.callPackage ./packages/jj-fzf/default.nix {};
  hijacker = pkgs.callPackage ./packages/hijacker {}; # Adaptation of my bash script by my good friend (IN RUST!!!) :3
}
