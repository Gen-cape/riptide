{
  coreutils,
  fetchFromGitHub,
  findutils,
  fzf,
  gawk,
  gitFull,
  gnugrep,
  gnused,
  jujutsu,
  stdenv,
  which,
}:
stdenv.mkDerivation rec {
  pname = "jj-fzf";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "tim-janik";
    repo = "jj-fzf";
    rev = "v${version}";
    hash = "sha256-a8h5H4uDsMHJvP/TuvkuCaw/uTR/Oe1lARPpqSzjqoQ=";
  };

  buildInputs = [jujutsu];

  nativeBuildInputs = [jujutsu];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 jj-fzf $out/bin/jj-fzf
    runHook postInstall
  '';

  nativeCheckInputs = [jujutsu];

  doCheck = true;
  checkPhase = ''
    # Ensure jj is available
    jj version
  '';

  # Patch the script to ensure all required dependencies are in PATH
  postPatch = ''
    sed -i '1i#!/usr/bin/env bash' jj-fzf
    patchShebangs jj-fzf
  '';

  # Add runtime dependencies to PATH
  propagatedBuildInputs = [
    coreutils
    findutils
    fzf
    gawk
    gitFull
    gnugrep
    gnused
    jujutsu
    which
  ];
}
