{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
  libGL,
  glib,
}:
stdenv.mkDerivation rec {
  pname = "sam-ba";
  version = "3.9.2";

  src = fetchurl {
    url = "https://github.com/atmelcorp/sam-ba/releases/download/v${version}/sam-ba_v${version}-linux_x86_64-24.04.tar.gz";
    sha256 = "5ac602eb79b6e87ebc26080ea2661de8ef6e1f1af7ecfe64c80a09e1718cbc4e";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
    libGL
    glib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/sam-ba $out/bin
    cp -a * $out/opt/sam-ba/

    ln -s $out/opt/sam-ba/sam-ba $out/bin/sam-ba

    runHook postInstall
  '';

  meta = with lib; {
    description = "Atmel SAM-BA In-System Programmer";
    homepage = "https://github.com/atmelcorp/sam-ba";
    sourceProvenance = with sourceTypes; [binaryNativeCode];
    license = licenses.bsd3;
    platforms = ["x86_64-linux"];
    mainProgram = "sam-ba";
  };
}
