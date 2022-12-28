(add-to-list 'load-path "~/.emacs.d/lisp")

;; Function declaration and default settings.
(require 'setup-default-settings)
(require 'custom-functions)

;; Common utilities.
(require 'setup-wm)
(require 'setup-projectile)
(require 'setup-appearance)
(require 'setup-evil)
(require 'setup-git)
(require 'setup-lsp)
(require 'setup-tree-sitter)
(require 'setup-formatters)
(require 'setup-common-dev-utilities)

;; Language specific utilities.
(require 'setup-markdown)
(require 'setup-org)
