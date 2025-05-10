{
  pkgs,
  rustPlatform,
  pipewire,
  llvmPackages,
  fetchFromGitHub,
  ...
}:
rustPlatform.buildRustPackage {
  pname = "hijacker";
  version = "0.1.0";

  # src = ./.;
  src = fetchFromGitHub {
    owner = "chilipizdrick";
    repo = "hijacker";
    rev = "master";
    sha256 = "sha256-yLkgufOoO/35IIerwSkrBMB+0L5Fq6XHQ6lWV+Ltv9Q=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-vCWzhaHsk6lu+OgNkEQ4/NdPdWvIpIu1UJ9sITP8L7k=";

  nativeBuildInputs = [
    llvmPackages.clang
    llvmPackages.libclang
    rustPlatform.bindgenHook
    pkgs.pkg-config
    pkgs.alsa-lib
  ];

  buildInputs = [
    pipewire
    pkgs.alsa-lib
    pkgs.alsa-lib.dev
  ];

  meta = with pkgs.lib; {
    description = "A Rust application for audio manipulation";
    homepage = "My source is that I made it the fuck up";
    license = licenses.mit;
    maintainers = with maintainers; [];
    platforms = platforms.linux;
  };
}
