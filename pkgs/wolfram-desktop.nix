{ addOpenGLRunpath
, autoPatchelfHook
, lib
, makeWrapper
, requireFile
, runCommand
, stdenv
, symlinkJoin
# dependencies
, alsa-lib
, cudaPackages
, cups
, dbus
, flite
, fontconfig
, freetype
, gcc-unwrapped
, glib
, gmpxx
, keyutils
, libGL
, libGLU
, libpcap
, libtins
, libuuid
, libxkbcommon
, libxml2
, llvmPackages_12
, matio
, mpfr
, ncurses
, opencv4
, openjdk11
, openssl
, pciutils
, tre
, unixODBC
, xkeyboard_config
, xorg
, zlib
}:

let
  name = "wolframe-desktop";
  version = "13.1.0";
  installer = "WolframDesktop_${version}_BNDL_LINUX_CN.sh";
  src = requireFile {
    name = installer;
    message = ''
      This nix expression requires that ${installer} is
      already part of the store. Find the file on your Mathematica CD
      and add it to the nix store with nix-store --add-fixed sha256 <FILE>.

      > You could download installer from: https://account.wolfram.com/products/downloads/wolfram-one
    '';
    sha256 = "0w9qqxydcljs878f6nyadi9fvk4r5pzzz7f9czsan4wdy4h7g3bz";
  };
in stdenv.mkDerivation {
  inherit name src version;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    cups.lib
    dbus
    flite
    fontconfig
    freetype
    glib
    gmpxx
    keyutils.lib
    libGL
    libGLU
    libpcap
    libtins
    libuuid
    libxkbcommon
    libxml2
    llvmPackages_12.libllvm.lib
    matio
    mpfr
    ncurses
    opencv4
    openjdk11
    openssl
    pciutils
    tre
    unixODBC
    xkeyboard_config
  ] ++ (with xorg; [
    libICE
    libSM
    libX11
    libXScrnSaver
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXinerama
    libXmu
    libXrandr
    libXrender
    libXtst
    libxcb
  ]);

  wrapProgramFlags = [
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ gcc-unwrapped.lib zlib ]}"
    "--prefix PATH : ${lib.makeBinPath [ stdenv.cc ]}"
    # Fix libQt errors - #96490
    "--set USE_WOLFRAM_LD_LIBRARY_PATH 1"
    # Fix xkeyboard config path for Qt
    "--set QT_XKB_CONFIG_ROOT ${xkeyboard_config}/share/X11/xkb"
  ];

  unpackPhase = ''
    runHook preUnpack
    # Find offset from file
    offset=$(${stdenv.shell} -c "$(grep -axm1 -e 'offset=.*' $src); echo \$offset" $src)
    tail -c +$(($offset + 1)) $src | tar -xf -
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    cd "$TMPDIR/Unix/Installer"
    mkdir -p "$out/lib/udev/rules.d"
    # Patch MathInstaller's shebangs and udev rules dir
    patchShebangs MathInstaller
    substituteInPlace MathInstaller \
      --replace /etc/udev/rules.d $out/lib/udev/rules.d
    # Remove PATH restriction, root and avahi daemon checks, and hostname call
    sed -i '
      s/^PATH=/# &/
      s/isRoot="false"/# &/
      s/^checkAvahiDaemon$/# &/
      s/`hostname`/""/
    ' MathInstaller
    # NOTE: some files placed under HOME may be useful
    XDG_DATA_HOME="$out/share" HOME="$TMPDIR/home" vernierLink=y \
      ./MathInstaller -execdir="$out/bin" -targetdir="$out/libexec/Mathematica" -auto -verbose -createdir=y
    # Check if MathInstaller produced any errors
    errLog="$out/libexec/Mathematica/InstallErrors"
    if [ -f "$errLog" ]; then
      echo "Installation errors:"
      cat "$errLog"
      return 1
    fi
    runHook postInstall
  '';

  preFixup = ''
    for bin in $out/libexec/Mathematica/Executables/*; do
      wrapProgram "$bin" ''${wrapProgramFlags[@]}
    done
  '';

  dontConfigure = true;
  dontBuild = true;

  # This is primarily an IO bound build; there's little benefit to building remotely
  preferLocalBuild = true;

  # All binaries are already stripped
  dontStrip = true;

  # NOTE: Some deps are still not found; ignore for now
  autoPatchelfIgnoreMissingDeps = true;
}
