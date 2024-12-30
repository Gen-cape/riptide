{...}: {
  imports = [
    ./devshells.nix
  ];
  perSystem = {pkgs, ...}: {
    packages = rec {
      sttt = pkgs.callPackage ./sttt/sttt.nix {};
      jujutsu-fzf = pkgs.callPackage ./jujutsu/jujutsu-fzf.nix {};
      default = sttt;
    };
  };
}
