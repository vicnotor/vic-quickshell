{
  rev,
  lib,
  stdenv,
  makeWrapper,
  quickshell,
}:
stdenv.mkDerivation {
  pname = "vic-quickshell";
  version = "${rev}";
  src = ./src;

  nativeBuildInputs = [makeWrapper];
  buildInputs = [quickshell];

  buildPhase = ''
    mkdir -p bin
  '';

  installPhase = ''
    makeWrapper ${quickshell}/bin/qs $out/bin/vic-quickshell \
    	--add-flags '-p ${./src}'
  '';

  meta = {
    description = "Vic's Quickshell";
    homepage = "https://github.com/vicnotor/vic-quickshell";
    license = lib.licenses.gpl3;
    mainProgram = "vic-quickshell";
  };
}
