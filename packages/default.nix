{...}: {
  imports = [
    ./devshells.nix
  ];
  perSystem = {pkgs, ...}: {
    packages = rec {
      sttt = pkgs.callPackage ./sttt {};
      jj-fzf = pkgs.callPackage ./jj-fzf {};
      drvinter = pkgs.callPackage ./drvinter {};
      ghostty = pkgs.callPackage ./ghostty {};
      tmsufolders = pkgs.callPackage ./tmsufolders {};
      tmsufs = pkgs.callPackage ./tmsufs {};
      quest = pkgs.callPackage ./quest {};
      keep-alive = pkgs.callPackage ./keep-alive {};
      display3d = pkgs.callPackage ./display3d {};
      fonts = (pkgs.callPackage ./lotr-fonts {}).all;
      uxn = pkgs.callPackage ./uxn {};
      numi-cli = pkgs.callPackage ./numi-cli {};
      notepad = uxn.notepad;
      calendar = uxn.calendar;
      m291 = uxn.m291;
      toml-bombadil = pkgs.callPackage ./toml-bombadil {};
      tray-tui = pkgs.callPackage ./tray-tui {};
      ulss = pkgs.callPackage ./ulss {};

      default = sttt;
    };
  };
}
