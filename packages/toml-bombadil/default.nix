{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libgit2,
  openssl,
  zlib,
  stdenv,
  darwin,
  gnupg, # Added GPG
  git, # Added Git
}:
rustPlatform.buildRustPackage rec {
  pname = "toml-bombadil";
  version = "4.0.0";
  src = fetchFromGitHub {
    owner = "oknozor";
    repo = "toml-bombadil";
    rev = version;
    hash = "sha256-+kH+Vgoob3RKOBnKXDATuJ63ajAjG2VPuBOn7lyzVe0=";
  };
  useFetchCargoVendor = true;
  # cargoHash = "sha256-iNOcn8MSeW5woTKaLH2bIsHuoT8XpDMaWUlCSlkeQ9Y=";
  cargoHash = "sha256-L+A40YYYwtholC5SJLKZ+mlOLlwm+8iRidCh8iGK1Us=";
  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs =
    [
      libgit2
      openssl
      zlib
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.CoreFoundation
      darwin.apple_sdk.frameworks.CoreServices
      darwin.apple_sdk.frameworks.Security
    ];
  checkInputs = [
    gnupg
    git
  ];
  env = {
    OPENSSL_NO_VENDOR = true;
  };

  # Skip the problematic tests that require external network or GPG setup
  checkFlags = [
    "--skip=git::test::should_clone_repository"
    "--skip=gpg::test::should_decrypt"
    "--skip=gpg::test::should_encrypt"
    "--skip=gpg::test::should_decrypt_from_file"
    "--skip=gpg::test::should_not_encrypt_unkown_gpg_user"
    "--skip=gpg::test::should_push_to_var"
  ];

  meta = {
    description = "A dotfile manager with templating";
    homepage = "https://github.com/oknozor/toml-bombadil";
    changelog = "https://github.com/oknozor/toml-bombadil/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [];
    mainProgram = "bombadil";
  };
}
