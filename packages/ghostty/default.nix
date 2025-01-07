{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "ghostty-animation-command";
  version = "unstable-2025-01-03";

  src = fetchFromGitHub {
    owner = "lukeshere";
    repo = "ghostty-animation-command";
    rev = "d84b52d17cf904d0d98bf2ed9a1e10144bc2a19a";
    hash = "sha256-hggqu4sJ9xWZUhnShlErpuZoV6wWHsapFu7oD/s6Fzw=";
  };

  cargoHash = "sha256-4fHu4zRENCPDj9FPCG349DO2zcU5KRjgtxJIE5SwcyY=";

  # Rename the binary in Cargo.toml before building
  patchPhase = ''
    substituteInPlace Cargo.toml \
      --replace 'name = "ghostty_animation"' 'name = "ghostty-animation-command"'
  '';
}
