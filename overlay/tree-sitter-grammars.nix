final: prev:

let
  mergeAttrs = builtins.foldl' (a: b: a // b) { };

  grammar-builder = { lang, location ? "src" }:
    let name = "tree-sitter-${lang}";
    in
    {
      "${name}" = prev.tree-sitter-grammars."${name}".overrideAttrs (_: {
        nativeBuildInputs = [ final.nodejs final.tree-sitter ];
        configurePhase = ''
          tree-sitter generate --abi 13 ${location}/grammar.json
        '';
      });
    };
  grammars-builder = langs: mergeAttrs (map grammar-builder langs);

  new-grammars = (grammars-builder [
    { lang = "c"; }
    { lang = "cpp"; }
    { lang = "python"; }
    { lang = "javascript"; }
    { lang = "typescript"; location = "typescript/src"; }
    { lang = "tsx"; location = "tsx/src"; }
    { lang = "bash"; }
    { lang = "css"; }
    { lang = "html"; }
    { lang = "json"; }
    { lang = "toml"; }
  ]);
in
prev.tree-sitter-grammars // new-grammars
