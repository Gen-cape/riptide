_: {
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        (writeShellScriptBin "bd" ''
          nix build .#default --no-substitute --out-link bd
        '')
        (writeShellScriptBin "rn" ''
          nix run --no-substitute
        '')
        # (pkgs.callPackage ./packages/jujutsu/jujutsu-fzf.nix {})
      ];
    };
  };
}
