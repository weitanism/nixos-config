{ pkgs }:

with pkgs;
let
  # TODO: Deduce `isWayland` from `config.programs.hyprland.enable`.
  isWayland = false;
  emacs = if isWayland then emacsPgtkNativeComp else emacsGit;
in
(emacsPackagesFor emacs).emacsWithPackages (epkgs:
  (with epkgs; [
    # Common utility
    counsel
    smex
    flycheck
    ivy
    ivy-hydra
    flx
    magit
    forge
    code-review
    projectile
    counsel-projectile
    use-package
    evil
    evil-leader
    evil-collection
    which-key
    avy
    evil-commentary
    helpful
    nix-mode
    direnv
    blamer
    neotree
    emacs-everywhere
    org
    org-contrib
    # Export org document in html format with colorized code blocks.
    htmlize
    # Export org document for hugo.
    ox-hugo
    # Window management
    golden-ratio
    # Editing
    company
    company-fuzzy
    wgrep
    iedit
    expand-region
    evil-iedit-state
    evil-surround
    yasnippet
    yasnippet-snippets
    undo-tree
    highlight-indent-guides
    goggles
    evil-goggles
    smartparens
    # tree-sitter powered packages.
    tree-sitter
    tree-sitter-langs
    evil-textobj-tree-sitter
    # Appearance
    base16-theme
    dashboard # splash page
    doom-themes
    doom-modeline
    all-the-icons
    nyan-mode
    kaolin-themes
    circadian
    diff-hl
    # Development
    lsp-mode
    lsp-ui
    lsp-ivy
    ccls
    epkgs.melpaPackages."clang-format+"
    tide
    web-mode
    imenu-list
    citre
    elisp-autofmt
    # prettier
    prettier-js
    protobuf-mode
    dockerfile-mode
    bazel
    fish-mode
    shfmt
    gitlab-ci-mode
    gitlab-ci-mode-flycheck
    eslintd-fix
    json-mode
    haskell-mode
    rainbow-mode
    blacken
    python-isort
    eldoc-box
    # For lsp-bridge
    posframe
    markdown-mode
    # For markdown
    web-server
    websocket
    markdown-toc
  ]))
