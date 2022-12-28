(add-to-list 'load-path "~/.emacs.d/git/maple-preview")
(use-package
 maple-preview
 :commands (maple-preview-mode)
 :config (setq maple-preview:auto-scroll nil))

(use-package markdown-mode :config (setq markdown-command "pandoc"))

(provide 'setup-markdown)
