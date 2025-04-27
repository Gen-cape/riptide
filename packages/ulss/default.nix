{
  lib,
  stdenv,
  fetchFromGitea,
  makeWrapper,
  umu-launcher,
  wget,
  gnused,
  gnugrep,
  coreutils,
}:
stdenv.mkDerivation rec {
  pname = "ulss";
  version = "unstable-2024-12-12";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "MrDraxs";
    repo = "ulss";
    rev = "5c177dabb87b08677bf2043dacee700b61d889a6";
    hash = "sha256-L1AJNeXwfcxGN3sRgrCgTnnw/Jyp4uZAfn3YrF6UjyU=";
  };

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    mkdir -p $out/bin
    cp scripts/ulss.sh $out/bin/ulss
    chmod +x $out/bin/ulss

    wrapProgram $out/bin/ulss \
      --prefix PATH : ${lib.makeBinPath [
      umu-launcher
      wget
      gnused
      gnugrep
      coreutils
    ]}
  '';

  meta = {
    description = "Umu-launcher is a bash script that automatic configure umu to launch games";
    homepage = "https://codeberg.org/MrDraxs/ulss";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [];
    mainProgram = "ulss";
    platforms = lib.platforms.all;
  };
}
