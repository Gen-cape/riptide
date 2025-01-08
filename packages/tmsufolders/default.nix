{writeShellScriptBin, ...}:
writeShellScriptBin "tmsufolders" (builtins.readFile ./tmsufolders.bash)
