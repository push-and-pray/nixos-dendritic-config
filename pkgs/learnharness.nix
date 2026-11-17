{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  importNpmLock,
  nodejs,
  autoPatchelfHook,
  makeWrapper,
  jetbrains-mono,
  source-sans,
}:

let
  pname = "learnharness";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "amosblomqvist";
    repo = "learnharness";
    rev = "v${version}";
    hash = "sha256-XkbLhhmRKv/fcNk0Dup+UF6mVNYmJFMGCJjk53HHe/U=";
  };

  pluginNames = [
    "flashcards"
    "coding-questions"
    "drawing-pad"
    "rich-code-blocks"
    "ui-showcase"
  ];

  pluginDeps = lib.genAttrs pluginNames (
    name:
    importNpmLock {
      npmRoot = "${src}/plugins/${name}";
    }
  );
in
buildNpmPackage {
  inherit
    pname
    version
    src
    nodejs
    ;

  npmDeps = importNpmLock {
    npmRoot = src;
  };
  inherit (importNpmLock) npmConfigHook;
  npmFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    NEXT_TELEMETRY_DISABLED = "1";
  };

  postPatch = ''
    mkdir -p app/fonts
    cp "${jetbrains-mono}/share/fonts/truetype/JetBrainsMono[wght].ttf" app/fonts/JetBrainsMono.ttf
    cp "${jetbrains-mono}/share/fonts/truetype/JetBrainsMono-Italic[wght].ttf" app/fonts/JetBrainsMono-Italic.ttf
    cp "${source-sans}/share/fonts/truetype/SourceSans3VF-Upright.ttf" app/fonts/SourceSans3.ttf
    cp "${source-sans}/share/fonts/truetype/SourceSans3VF-Italic.ttf" app/fonts/SourceSans3-Italic.ttf

    substituteInPlace app/layout.tsx \
      --replace-fail 'import { JetBrains_Mono, Source_Sans_3 } from "next/font/google";' 'import localFont from "next/font/local";' \
      --replace-fail 'const ui = JetBrains_Mono({ subsets: ["latin"], variable: "--font-jetbrains" });' 'const ui = localFont({ src: [{ path: "./fonts/JetBrainsMono.ttf", style: "normal" }, { path: "./fonts/JetBrainsMono-Italic.ttf", style: "italic" }], variable: "--font-jetbrains" });' \
      --replace-fail 'const prose = Source_Sans_3({ subsets: ["latin"], variable: "--font-sans3" });' 'const prose = localFont({ src: [{ path: "./fonts/SourceSans3.ttf", style: "normal" }, { path: "./fonts/SourceSans3-Italic.ttf", style: "italic" }], variable: "--font-sans3" });'
  '';

  preBuild = ''
    export HOME="$TMPDIR"
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: deps: ''
        if node -e 'const p = require("./plugins/${name}/package.json"); process.exit(p.scripts?.sdk ? 0 : 1)'; then
          npm --prefix "plugins/${name}" run sdk
        fi
        (
          cd "plugins/${name}"
          sed "s|${src}/plugins/${name}/.sdk|.sdk|g" "${deps}/package.json" > package.json
          sed "s|${src}/plugins/${name}/.sdk|.sdk|g" "${deps}/package-lock.json" > package-lock.json
          npm install --offline --ignore-scripts --progress=false --fund=false
        )
      '') pluginDeps
    )}
  '';

  buildPhase = ''
    runHook preBuild

    npm run build
    node scripts/build-server.mjs

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/learnharness" "$out/bin"
    cp -r .next/standalone/. "$out/lib/learnharness/"

    makeWrapper "${lib.getExe nodejs}" "$out/bin/learnharness" \
      --add-flags "$out/lib/learnharness/server.js" \
      --set NODE_ENV production \
      --set NEXT_TELEMETRY_DISABLED 1

    runHook postInstall
  '';

  meta = with lib; {
    description = "An agent harness for learning: adaptive teaching, practice, and a persistent knowledge graph";
    homepage = "https://github.com/amosblomqvist/learnharness";
    license = licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "learnharness";
  };
}
