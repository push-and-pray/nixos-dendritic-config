{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  addDriverRunpath,
  makeWrapper,
  wayland,
  libxkbcommon,
  vulkan-loader,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  libxcb,
  fontconfig,
  freetype,
  dbus,
  openssl,
}:

let
  runtimeLibs = [
    wayland
    libxkbcommon
    vulkan-loader
    libGL
    libx11
    libxcursor
    libxi
    libxrandr
    libxcb
    fontconfig
    freetype
    dbus
    openssl
  ];
in
stdenv.mkDerivation rec {
  pname = "artcraft-launcher";
  version = "0.8.1";

  src = fetchurl {
    url = "https://github.com/storytold/craft-launcher/releases/download/v${version}/artcraft-launcher-${version}-linux-x86_64.tar.gz";
    hash = "sha256-RJpq7gv0NeUfPrGbTN34OyZ1JuQl4hp50oM1tqbLbTc=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    addDriverRunpath
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r bin share $out/

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/artcraft-launcher \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"
  '';

  meta = with lib; {
    description = "Launcher for the ArtCraft / Craft creative application suite";
    homepage = "https://github.com/storytold/craft-launcher";
    license = with licenses; [
      mit
      asl20
    ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "artcraft-launcher";
  };
}
