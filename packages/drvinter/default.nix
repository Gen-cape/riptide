{pkgs ? import <nixpkgs> {}}: let
  # Create a wrapper script that copies inter.bash to interactive.bash
  wrapper = pkgs.writeScriptBin "interactive-wrapper" ''
    #!${pkgs.bash}/bin/bash
    cp ${./inter.bash} ./interactive.bash
    chmod +x ./interactive.bash
  '';
in
  wrapper
