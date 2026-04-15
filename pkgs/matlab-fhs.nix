{
  lib,
  buildFHSEnv,
  bash,
  coreutils,
  cacert,
  glibcLocales,
  libatomic_ops,
  gcc,
  libxcrypt-legacy,
  libtirpc,
  libtool,
  linux-pam,
  zlib,
  libcap,
  alsa-lib,
  libsndfile,
  libGL,
  libdrm,
  mesa,
  pixman,
  glib,
  gtk3,
  atk,
  gdk-pixbuf,
  cairo,
  pango,
  fontconfig,
  fribidi,
  harfbuzz,
  gst_all_1,
  wayland,
  libX11,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxfixes,
  libxfont_2,
  libxft,
  libxinerama,
  libxrandr,
  libxt,
  libxtst,
  libxxf86vm,
  libice,
  libsm,
  libgbm,
  libxext,
  libxrender,
  freetype,
  nspr,
  nss,
  nettle,
  cups,
  systemd,
  util-linux,
  dbus,
  ncurses,
  gnumake,
  net-tools,
  procps,
  sudo,
  unzip,
  debianutils,
  symlinkJoin,
  makeDesktopItem,
  fetchurl,
  matlabRoot ? "$HOME/.Matlab",
}: let
  matlabFHS = buildFHSEnv {
    name = "matlab-fhs";

    targetPkgs = pkgs: [
      bash
      coreutils
      debianutils
      unzip
      gnumake
      net-tools
      procps
      sudo
      cacert
      glibcLocales

      pkgs.glibc
      libatomic_ops
      gcc.cc.lib
      libxcrypt-legacy
      libcap
      zlib

      libtool
      linux-pam
      libtirpc

      alsa-lib
      libsndfile

      libGL
      libdrm
      mesa

      glib

      gtk3
      atk
      gdk-pixbuf
      cairo
      pango
      pixman
      fribidi
      harfbuzz
      fontconfig
      freetype

      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base

      wayland

      libX11
      libxcomposite
      libxcursor
      libxdamage
      libxfixes
      libxfont_2
      libxft
      libxinerama
      libxrandr
      libxt
      libxtst
      libxxf86vm
      libice
      libsm
      libgbm
      libxext
      libxrender

      nspr
      nss
      nettle

      cups

      systemd
      util-linux
      dbus
      ncurses
    ];

    profile = ''
      export LANG=en_US.UTF-8
      export LC_ALL=en_US.UTF-8
      export LIBGL_ALWAYS_SOFTWARE=0
      export PATH="${matlabRoot}/bin:$PATH"
    '';

    meta = {
      description = "FHS environment for running MATLAB";
      platforms = lib.platforms.linux;
    };
  };
  matlabIcon = fetchurl {
    url = "https://upload.wikimedia.org/wikipedia/commons/2/21/Matlab_Logo.png";
    hash = "sha256-fw0KuwIP018QcsQzfs+CicBBQdy4c6cSVmr9rK6iLsw=";
  };
  desktopItem = makeDesktopItem {
    name = "matlab";
    desktopName = "MATLAB";
    exec = "${matlabFHS}/bin/matlab-fhs -c matlab";
    icon = "${matlabIcon}";
    terminal = false;
    categories = ["Science" "Math"];
    comment = "Scientific computing environment";
  };
in
  symlinkJoin {
    name = "matlab-desktop-env";
    paths = [matlabFHS desktopItem];
  }
