{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "display3d";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "renpenguin";
    repo = "display3d";
    rev = "v${version}";
    hash = "sha256-1EAqnLlX/J9KkPKwa1LlLt8pvIS/eZth1OgVei82eP4=";
  };

  cargoHash = "sha256-VKnB5iiEAFB4rE2le0KZyqvDSrnLzDGRirmR9q11NRE=";

  meta = {
    description = "A command line interface for rendering and animating 3D objects";
    homepage = "https://github.com/renpenguin/display3d";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "display3d";
  };
}
