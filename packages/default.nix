{...}: {
  imports = [
    ./devshells.nix
  ];
  perSystem = {pkgs, ...}: {
    packages = rec {
      sttt = pkgs.callPackage ./sttt {};
      jujutsu-fzf = pkgs.callPackage ./jujutsu {};
      drvinter = pkgs.callPackage ./drvinter {};
      ghostty = pkgs.callPackage ./ghostty {};
      default = sttt;
    };
  };
}
