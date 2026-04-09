{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  squashfsTools,
  libisoburn,
  grub2,
}:
buildGoModule rec {
  pname = "elemental";
  version = "2.3.2";

  src = fetchFromGitHub {
    owner = "rancher";
    repo = "elemental-toolkit";
    rev = "v${version}";
    hash = "sha256-WtHXgVwAQZPaFIUO5wOm/tlD92E4ES3CwZaWXIeYmLw=";
  };

  vendorHash = null;

  nativeBuildInputs = [makeWrapper];

  ldflags = [
    "-w"
    "-s"
    "-X github.com/rancher/elemental-toolkit/v2/internal/version.version=v${version}"
    "-X github.com/rancher/elemental-toolkit/v2/internal/version.gitCommit=nixpkgs"
  ];

  preBuild = ''
    go generate ./...
  '';

  postInstall = ''
    mv $out/bin/elemental-toolkit $out/bin/elemental
    wrapProgram $out/bin/elemental \
      --prefix PATH : ${lib.makeBinPath [
      squashfsTools
      libisoburn
      grub2
    ]}
  '';

  doCheck = false;

  meta = with lib; {
    description = "Toolkit to build, ship and maintain cloud-init driven Linux derivatives based on container images";
    homepage = "https://github.com/rancher/elemental-toolkit";
    license = licenses.asl20;
    mainProgram = "elemental";
  };
}
