{ lib, stdenv, fetchzip, ... }:

stdenv.mkDerivation rec {
  pname = "cattpuccin-cursors";
  version = "1.0";
  src = fetchzip {
    url =
      "https://github.com/Ruixi-rebirth/Catppuccin-cursor/archive/refs/tags/1.0.zip";
    sha256 = "sha256-RCEVxeo3oBNqHogxWM/YqfPoQotirSQTMw15zCahWto=";
  };
  installPhase = ''
    mkdir -p $out/share/icons/Catppuccin-Frappe-Dark
    cp -va index.theme cursors $out/share/icons/Catppuccin-Frappe-Dark
  '';
}
