{
  lib,
  stdenv,
  uxn,
  mpg123,
}: let
  # Helper function to create Uxn program derivations
  makeUxnProgram = {
    name,
    src,
    description ? "",
  }:
    stdenv.mkDerivation {
      pname = name;
      version = "0.1.0";
      inherit src;

      # Add uxn to buildInputs
      nativeBuildInputs = [uxn];

      # Disable the unpack phase since we're working with single files
      dontUnpack = true;

      buildPhase = ''
        # Copy the source file to the build directory
        cp $src ${name}.tal
        # Assemble it using the full path to uxnasm
        ${uxn}/bin/uxnasm ${name}.tal ${name}.rom
      '';

      installPhase = ''
        mkdir -p $out/bin $out/share/${name}
        cp ${name}.rom $out/share/${name}/
        cat > $out/bin/${name} << EOF
        #!/bin/sh
        exec ${uxn}/bin/uxnemu $out/share/${name}/${name}.rom "\$@"
        EOF
        chmod +x $out/bin/${name}
      '';

      meta = with lib; {
        inherit description;
        homepage = "https://wiki.xxiivv.com/site/uxn.html";
        license = licenses.mit;
        platforms = platforms.all;
        maintainers = [];
      };
    };
in {
  notepad = makeUxnProgram {
    name = "notepad";
    src = ./notepad.tal.txt;
    description = "A port of the Macintosh System 7 Notepad for Uxn/Varvara";
  };

  calendar = makeUxnProgram {
    name = "calendar";
    src = ./calendar.tal.txt;
    description = "Calendar program inspired by the Macintosh System 7 Notepad for Uxn/Varvara";
  };

  m291 =
    (makeUxnProgram {
      name = "m291";
      src = ./m291.tal.txt;
      description = "An mpg123 client for Uxn/Varvara";
    })
    .overrideAttrs (oldAttrs: {
      buildInputs = (oldAttrs.buildInputs or []) ++ [mpg123];
    });
}
