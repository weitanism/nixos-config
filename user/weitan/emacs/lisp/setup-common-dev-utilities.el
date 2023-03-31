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

(provide 'setup-common-dev-utilities)
