(use-package
 evil
 :init
 (setq evil-want-integration t)
 (setq evil-want-keybinding nil)
 (setq evil-lookup-func #'helpful-at-point)
 (setq-default evil-symbol-word-search t)
 :bind
 ("C-u" . evil-scroll-up)
 ("C-i" . evil-jump-forward)
 ("C-o" . evil-jump-backward)
 :config
 (setq select-enable-clipboard t)
 (global-evil-leader-mode)
 (evil-mode 1)
 (evil-collection-init))

(use-package
 evil-leader
 :commands (global-evil-leader-mode)
 :config (evil-leader/set-leader "<SPC>")
 (evil-leader/set-key
  ;; Common
  "<SPC>"
  'counsel-M-x
  "qq"
  'save-buffers-kill-emacs
  "xo"
  'org-open-at-point
  ;; File
  "pf"
  'counsel-projectile-find-file
  "pp"
  'counsel-projectile-switch-project
  "ff"
  'counsel-find-file
  "fr"
  'counsel-recentf
  "fs"
  'save-buffer
  "fc"
  'spacemacs/save-as
  "fR"
  'spacemacs/rename-current-buffer-file
  "fD"
  'delete-current-buffer-file
  ;; Window
  "wo"
  'spacemacs/toggle-maximize-buffer
  "ww"
  'other-window
  "ww"
  'other-window
  "wh"
  'evil-window-left
  "wj"
  'evil-window-down
  "wk"
  'evil-window-up
  "wl"
  'evil-window-right
  "ws"
  'split-window-below
  "wv"
  'split-window-right
  "wd"
  'evil-window-delete
  ;; Jumping
  "TAB"
  'evil-switch-to-windows-last-buffer
  "bb"
  'ivy-switch-buffer
  "bd"
  'spacemacs/kill-this-buffer
  "bu"
  'reopen-killed-file
  "jj"
  'evil-avy-goto-char-timer
  "js"
  'evil-avy-goto-symbol-1
  "jl"
  'evil-avy-goto-line
  "jw"
  'evil-avy-goto-word-1
  "jb"
  'counsel-bookmark
  "i"
  'imenu-list-smart-toggle
  ;; Editing
  ";"
  'evil-commentary
  ;; Searching
  "ss"
  'swiper
  "sS"
  'swiper-thing-at-point
  "sf"
  'counsel-rg-at-interactive-dir
  "sr"
  'ivy-resume
  "*"
  'counsel-projectile-rg-thing-at-point
  "/"
  'counsel-projectile-rg
  ;; Flymake
  "en"
  'flymake-goto-next-error
  "ep"
  'flymake-goto-prev-error
  "el"
  'flymake-show-buffer-diagnostics
  ;; Help
  "hk"
  'helpful-key
  "hf"
  'helpful-function
  "hv"
  'helpful-variable))

(use-package evil-iedit-state)

(use-package evil-surround :config (global-evil-surround-mode 1))

(use-package evil-commentary :config (evil-commentary-mode))

(use-package
 goggles
 ;; :hook ((prog-mode text-mode) . goggles-mode)
 :config
 (setq-default goggles-pulse t)) ;; set to nil to disable pulsing

(use-package
 evil-goggles
 :hook ((goggles-mode) evil-goggles-mode)
 ;; optionally use diff-mode's faces; as a result, deleted text
 ;; will be highlighed with `diff-removed` face which is typically
 ;; some red color (as defined by the color theme)
 ;; other faces such as `diff-added` will be used for other actions
 (evil-goggles-use-diff-faces))

(use-package
 smartparens
 :config (require 'smartparens-config)
 :hook ((prog-mode) . smartparens-mode))

(provide 'setup-evil)
