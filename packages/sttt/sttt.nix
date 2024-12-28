# default.nix
{
  lib,
  python3Packages,
}:
python3Packages.buildPythonApplication rec {
  pname = "sttt";
  version = "0.1.0.dev20240805";

  src = ./.;

  buildInputs = [python3Packages.setuptools];

  preBuild = ''
        cat > setup.py << EOF
    from setuptools import setup

    setup(
        name='${pname}',
        version='${version}',
        py_modules=['sttt'],
        entry_points={
            'console_scripts': [
                'sttt=sttt:main',
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

  postPatch = ''
    chmod +x sttt.py
    sed -i '1i#!/usr/bin/env python3' sttt.py
  '';
  #
  # meta = with lib; {
  #   description = "STTT Python application";
  #   homepage = "https://github.com/flick0/sttt";
  #   license = licenses.mit;
  #   maintainers = with lib.maintainers; [yourName];
  # };
}
