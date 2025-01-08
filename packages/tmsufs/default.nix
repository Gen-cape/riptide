{writeShellScriptBin, ...}:
writeShellScriptBin "tmsufs" (builtins.readFile ./tmsufs.bash)
