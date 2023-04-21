(use-package
 ivy
 :defer t
 :bind
 (:map
  ivy-minibuffer-map
  ("C-j" . ivy-next-line)
  ("C-k" . ivy-previous-line)
  :map
  ivy-switch-buffer-map
  ("C-j" . ivy-next-line)
  ("C-k" . ivy-previous-line))
 :config (setq ivy-initial-inputs-alist nil)
 (setq ivy-re-builders-alist
       '((read-file-name-internal . ivy--regex-fuzzy)
         (counsel-recentf . ivy--regex-fuzzy)
         (t . ivy--regex-ignore-order)))
 (setq completing-read-function 'ivy-completing-read)
 (ivy-define-key
  ivy-minibuffer-map (kbd "C-<return>") 'ivy-immediate-done))

(use-package counsel)
(use-package counsel-projectile)

(use-package
 all-the-icons-ivy-rich
 :config (all-the-icons-ivy-rich-mode 1))

(use-package ivy-rich :config (ivy-rich-mode 1))

(use-package
 which-key
 :config
 (setq which-key-idle-delay 0.5)
 (setq which-key-idle-secondary-delay 0.05)
 (which-key-mode))

(use-package
 expand-region
 :config
 (global-set-key (kbd "C-=") 'er/expand-region)
 (global-set-key (kbd "C--") 'er/contract-region))

(use-package
 neotree
 :after (evil evil-leader)
 :config
 (setq neo-smart-open t)
 (setq neo-window-width 30)
 (evil-define-key 'normal neotree-mode-map (kbd "TAB") 'neotree-enter)
 (evil-define-key
  'normal neotree-mode-map (kbd "p") 'neotree-quick-look)
 (evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
 (evil-define-key 'normal neotree-mode-map (kbd "RET") 'neotree-enter)
 (evil-define-key 'normal neotree-mode-map (kbd "r") 'neotree-refresh)
 (evil-define-key
  'normal neotree-mode-map (kbd "j") 'neotree-next-line)
 (evil-define-key
  'normal neotree-mode-map (kbd "k") 'neotree-previous-line)
 (evil-define-key
  'normal neotree-mode-map (kbd "A") 'neotree-stretch-toggle)
 (evil-define-key
  'normal neotree-mode-map (kbd "H") 'neotree-hidden-file-toggle)
 (evil-leader/set-key "0" 'neotree-toggle))

(use-package
 undo-tree
 :after (evil)
 :init
 (setq undo-tree-visualizer-timestamps t)
 (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo")))
 (global-undo-tree-mode)
 (evil-define-key nil evil-normal-state-map (kbd "u") 'undo-tree-undo)
 (evil-define-key
  nil evil-normal-state-map (kbd "C-r") 'undo-tree-redo))

(use-package
 imenu-list
 :config
 (setq imenu-list-focus-after-activation t)
 (setq imenu-list-auto-resize t))

(use-package avy :config (setq avy-timeout-seconds 0.3))

(use-package flycheck)

(use-package yasnippet :config (yas-global-mode 1))

(use-package direnv :config (direnv-mode))

(save-place-mode t)

(add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode))
(add-to-list 'auto-mode-alist '("\\.Dockerfile\\'" . dockerfile-mode))

(add-hook 'kill-buffer-hook #'add-file-to-killed-file-list)

;; TODO: Setup sdcv following https://github.com/manateelazycat/sdcv
(use-package
 multi-translate
 :config
 (with-eval-after-load 'evil
   (evil-define-key
    nil
    evil-normal-state-map
    (kbd "C-t")
    'multi-translate-at-point
    (kbd "q")
    'kill-buffer-and-window)))

;; Setup flyspell. Modified from
;; https://www.emacswiki.org/emacs/FlySpell.
(defun flyspell-on-for-buffer-type ()
  "Enable Flyspell appropriately for the major mode of the current
buffer.  Uses `flyspell-prog-mode' for modes derived from
`prog-mode', so only strings and comments get checked.  All other
buffers get `flyspell-mode' to check all text.  If flyspell is
already enabled, does nothing."
  (interactive)
  (if (not (symbol-value flyspell-mode)) ; if not already on
      (progn
        (if (derived-mode-p 'prog-mode)
            (progn
              (message "Flyspell on (code)")
              (flyspell-prog-mode))
          (progn
            (message "Flyspell on (text)")
            (flyspell-mode 1))))))

(defun flyspell-toggle ()
  "Turn Flyspell on if it is off, or off if it is on.  When turning
on, it uses `flyspell-on-for-buffer-type' so code-vs-text is
handled appropriately."
  (interactive)
  (if (symbol-value flyspell-mode)
      (progn ; flyspell is on, turn it off
        (message "Flyspell off")
        (flyspell-mode -1))
    ; else - flyspell is off, turn it on
    (flyspell-on-for-buffer-type)))

(use-package flyspell :config (setq flyspell-issue-message-flag nil))

;; Colorize compile mode buffer.
(use-package
 ansi-color
 :hook (compilation-filter . ansi-color-compilation-filter))

(provide 'setup-common-dev-utilities)
