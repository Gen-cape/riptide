{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  makeWrapper,
}: let
  pname = "numi-cli";
  version = "0.1.0";

  # Define the system-specific details
  systemMap = {
    x86_64-linux = "x86_64-unknown-linux-musl";
    aarch64-linux = "aarch64-unknown-linux-musl";
    x86_64-darwin = "x86_64-apple-darwin";
    aarch64-darwin = "aarch64-apple-darwin";
  };

  platform = systemMap.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchzip {
      url = "https://s3.numi.io/cli/latest/numi-cli-${platform}.tar.gz";
      sha256 = "sha256-JEnVXggLE5+FI27imtoehuyUsxTs+s/NYZ6kzMwxxQU=";
      stripRoot = false;
    };

    # For Linux builds we need autoPatchelfHook to handle dynamic libraries
    nativeBuildInputs = lib.optionals stdenv.isLinux [autoPatchelfHook] ++ [makeWrapper];

    # Simple installation: copy the binary to the bin directory
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp numi-cli $out/bin/
      chmod +x $out/bin/numi-cli
      runHook postInstall
    '';

    meta = with lib; {
      description = "Command-line calculator app that allows natural language input";
      homepage = "https://github.com/nikolaeu/numi";
      license = licenses.unfree; # Update with the actual license if known
      platforms = builtins.attrNames systemMap;
      mainProgram = "numi-cli";
    };
  }
