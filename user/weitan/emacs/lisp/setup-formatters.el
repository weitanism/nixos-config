(add-function :after after-focus-change-function #'save-all)

(use-package
 shfmt
 :init
 (setq shfmt-arguments
       '("--indent=2" "--case-indent" "--binary-next-line"))
 (add-hook 'sh-mode-hook 'shfmt-on-save-mode)
 (add-hook
  'sh-mode-hook
  (lambda () (define-key sh-mode-map (kbd "C-c C-f") 'shfmt))))

(use-package
 clang-format+
 :config
 (setq-default clang-format-fallback-style "google")
 (add-hook 'c-mode-common-hook #'clang-format+-mode))

(use-package bazel :init (setq bazel-buildifier-before-save t))

(use-package
 elisp-autofmt
 :init
 (add-hook
  'emacs-lisp-mode-hook
  (lambda ()
    (add-hook 'before-save-hook 'elisp-autofmt-buffer nil t))))

(provide 'setup-formatters)
