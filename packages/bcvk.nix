{
  lib,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  pkg-config,
  openssh,
}:
rustPlatform.buildRustPackage rec {
  pname = "bcvk";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "bootc-dev";
    repo = "bcvk";
    rev = "v${version}";
    hash = "sha256-P6ths5SqKf6Y0OIFBBIVMd1GD96nF5yySkQ0jjwMjb0=";
  };

  cargoHash = "sha256-DYHptCvh92Ml/LViVgR0ZFXvxhH3rEQs+jpp2Uvgmw8=";

  nativeBuildInputs = [
    pkg-config
    openssh
  ];

  buildInputs = [
    openssl
  ];

  meta = with lib; {
    description = "Bootc virtualization kit - launch ephemeral VMs from bootc containers";
    homepage = "https://github.com/bootc-dev/bcvk";
    license = licenses.asl20;
    mainProgram = "bcvk";
    platforms = platforms.linux;
  };
}
