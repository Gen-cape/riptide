{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) callPackageWith;
  inherit (pkgs) python3Packages;
in rec {
  call = callPackageWith;

  buildOneFilePythonApp = {
    pname,
    version ? "0.1.0.dev20240805",
    src,
    maintainer ? "me",
    homepage ? "none",
    license ? "dont touch",
  }:
    python3Packages.buildPythonApplication {
      inherit pname version src;
      buildInputs = [python3Packages.setuptools];

      # Define setup.py during the preBuild phase
      preBuild = ''
          cat > setup.py << EOF
        from setuptools import setup

        setup(
            name='${pname}',
            version='${version}',
            py_modules=['${pname}'],
            entry_points={
                'console_scripts': [
                    '${pname}=${pname}:main',
                ],
            },
            classifiers=[
                'Programming Language :: Python :: 3',
                'Operating System :: OS Independent',
            ],
            python_requires='>=3.6',
        )
        EOF
      '';

      # Modify the Python script to be executable by adding a shebang
      postPatch = ''
        chmod +x ${pname}.py
        sed -i '1i#!/usr/bin/env python3' ${pname}.py
      '';

      meta = with lib; {
        description = "A simple Python application: ${pname}.";
        homepage = homepage;
        license = license; # Default to MIT if not specified
        maintainers = with lib.maintainers; [maintainer]; # Replace with actual maintainer
      };
    };
}
