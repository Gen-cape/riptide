{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "quest";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "Fabian-G";
    repo = "quest";
    rev = "v${version}";
    hash = "sha256-hdzZP+dHnDoAYb5Zrl2BHQl+erxkkLdwhK4qRVz2Pag=";
  };

  vendorHash = "sha256-6uU4/fbONRbHdhWZlBvpVo8Rorzq0uvuhVddIDfbjU8=";

  # Skip tests that require filesystem access
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/Fabian-G/quest/cmd.version=${version}"
    "-X=github.com/Fabian-G/quest/cmd.commit=${src.rev}"
    "-X=github.com/Fabian-G/quest/cmd.date=1970-01-01T00:00:00Z"
    "-X=github.com/Fabian-G/quest/cmd.builtBy=goreleaser"
  ];

  meta = {
    description = "Todo.txt CLI that aims to support (almost) any workflow";
    homepage = "https://github.com/Fabian-G/quest";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [];
    mainProgram = "quest";
  };
}
