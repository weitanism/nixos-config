pkgs: { name, text, deps ? [ ] }:

let
  derivation = pkgs.writeShellScriptBin name ''
    for i in ${pkgs.lib.concatStringsSep " " deps}; do
      export PATH="$i/bin:$PATH"
    done

    ${text}
  '';
in
"${derivation}/bin/${name}"

