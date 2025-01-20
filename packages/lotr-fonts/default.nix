{
  lib,
  stdenvNoCC,
  unzip,
}: let
  # Helper function to create font derivations
  mkFontDerivation = {
    pname,
    version,
    description,
  }:
    stdenvNoCC.mkDerivation {
      inherit pname version;

      src = ./. + "/${pname}.zip";

      nativeBuildInputs = [unzip];

      dontPatch = true;
      dontConfigure = true;
      dontBuild = true;
      doCheck = false;
      dontFixup = true;

      unpackPhase = ''
        runHook preUnpack

        mkdir -p source
        cd source
        unzip $src

        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/fonts/truetype
        find . -type f -name "*.ttf" -o -name "*.TTF" | \
          while read -r font; do
            install -Dm644 "$font" "$out/share/fonts/truetype/"
          done

        runHook postInstall
      '';

      meta = with lib; {
        inherit description;
        license = licenses.unfree;
        platforms = platforms.all;
      };
    };

  aniron = mkFontDerivation {
    pname = "aniron";
    version = "1.0";
    description = "Aniron font from Lord of the Rings";
  };

  kelt = mkFontDerivation {
    pname = "kelt";
    version = "1.0";
    description = "Kelt font family from Lord of the Rings";
  };

  ringbearer = mkFontDerivation {
    pname = "ringbearer";
    version = "1.0";
    description = "Ringbearer font from Lord of the Rings";
  };
in {
  inherit aniron kelt ringbearer;

  # Main derivation that includes all fonts
  all = stdenvNoCC.mkDerivation {
    pname = "lotr-fonts";
    version = "1.0";

    dontUnpack = true;
    dontPatch = true;
    dontConfigure = true;
    dontBuild = true;
    doCheck = false;
    dontFixup = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/fonts/truetype
      ln -s ${aniron}/share/fonts/truetype/* $out/share/fonts/truetype/
      ln -s ${kelt}/share/fonts/truetype/* $out/share/fonts/truetype/
      ln -s ${ringbearer}/share/fonts/truetype/* $out/share/fonts/truetype/

      runHook postInstall
    '';

    meta = with lib; {
      description = "Collection of Lord of the Rings fonts including Aniron, Kelt, and Ringbearer";
      license = licenses.unfree;
      platforms = platforms.all;
    };
  };
}
