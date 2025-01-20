{
  lib,
  buildGoModule,
  fetchFromGitHub,
  glib,
  systemd,
  xorg,
}:
buildGoModule rec {
  pname = "keep-alive";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "stigoleg";
    repo = "keep-alive";
    rev = "v${version}";
    hash = "sha256-E8VRCzrvyPA4oxS+JB19JzEH5C8evv8cJBUtyPAu4+w=";
  };

  vendorHash = "sha256-ffMPyWfwRDJWofd3AVyrQn4GNM9F4S3jy9aWuXPk9P4=";

  # Disable tests as they require system-specific functionality
  doCheck = false;

  buildInputs = [
    glib
    systemd
    xorg.xset
  ];

  nativeBuildInputs = [
    glib
  ];

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${version}"
  ];

  # Specify the binary name to match the output
  postInstall = ''
    mv $out/bin/keepalive $out/bin/keep-alive
  '';

  meta = {
    description = "Keep-Alive is a lightweight, cross-platform utility to prevent your system from sleeping. Perfect for uninterrupted downloads, active connections, or long-running tasks";
    homepage = "https://github.com/stigoleg/keep-alive";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [];
    mainProgram = "keep-alive";
    platforms = lib.platforms.linux;
  };
}
