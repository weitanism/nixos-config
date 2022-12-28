(defconst light-theme-name 'doom-gruvbox-light)
(defconst dark-theme-name 'doom-gruvbox)

;; Default font size.
(set-face-attribute 'default nil :family "VictorMono" :height 180)

(set-face-attribute 'font-lock-preprocessor-face nil
                    :slant 'italic
                    :foreground "#6677aa")

(defun light-theme ()
  (load-theme light-theme-name t)
  (set-face-attribute 'font-lock-comment-face nil :slant 'italic)
  (set-face-attribute 'font-lock-keyword-face nil :slant 'italic)
  (set-face-attribute 'isearch nil :box nil)
  ;; For highlight-indent-guides.
  (setq highlight-indent-guides-auto-character-face-perc 40)
  (setq highlight-indent-guides-auto-top-character-face-perc 60))
(defun dark-theme ()
  (load-theme dark-theme-name t)
  (set-face-attribute 'font-lock-comment-face nil :slant 'italic)
  (set-face-attribute 'font-lock-keyword-face nil :slant 'italic)
  (set-face-attribute 'isearch nil :box nil)
  ;; For highlight-indent-guides.
  (setq highlight-indent-guides-auto-character-face-perc 100)
  (setq highlight-indent-guides-auto-top-character-face-perc 200))

(add-to-list
 'display-buffer-alist
 '("*Async Shell Command*" . (display-buffer-no-window . nil)))
(defun set-system-theme-to-dark ()
  (async-shell-command "env EMACS=false set-system-theme dark"))
(defun set-system-theme-to-light ()
  (async-shell-command "env EMACS=false set-system-theme light"))

(defun dark ()
  (interactive)
  (dark-theme)
  (set-system-theme-to-dark))
(defun light ()
  (interactive)
  (light-theme)
  (set-system-theme-to-light))

(use-package
 all-the-icons
 :if (display-graphic-p)
 :config (setq all-the-icons-scale-factor 1.2))

(use-package
 doom-themes
 :config
 ;; Global settings (defaults)
 (setq
  doom-themes-enable-bold t ; if nil, bold is universally disabled
  doom-themes-enable-italic t) ; if nil, italics is universally disabled
 (dark-theme)
 ;; Enable flashing mode-line on errors
 (doom-themes-visual-bell-config)
 ;; Enable custom neotree theme (all-the-icons must be installed!)
 (doom-themes-neotree-config)
 ;; or for treemacs users
 (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
 (doom-themes-treemacs-config)
 ;; Corrects (and improves) org-mode's native fontification.
 (doom-themes-org-config))

(use-package
 doom-modeline
 :init (doom-modeline-mode 1)
 :config (setq doom-modeline-height 25))

;; (use-package circadian
;;   :config
;;   (setq calendar-latitude 40.0)
;;   (setq calendar-longitude 116.3)
;;   (setq circadian-themes '((:sunrise . light-theme-name)
;;                            (:sunset  . dark-theme-name)))
;;   (add-hook 'circadian-after-load-theme-hook
;;             #'(lambda (theme)
;;                 (set-face-attribute 'font-lock-comment-face nil :slant 'italic)
;;                 (set-face-attribute 'font-lock-keyword-face nil :slant 'italic)
;;                 (if (string= theme light-theme-name)
;;                     (set-system-theme-to-light)
;;                   (set-system-theme-to-dark))))
;;   (circadian-setup))

(use-package
 rainbow-mode
 :config
 (add-to-list 'rainbow-html-colors-major-mode-list 'c-mode)
 (add-to-list 'rainbow-html-colors-major-mode-list 'c++-mode)
 (add-to-list 'rainbow-html-colors-major-mode-list 'emacs-lisp-mode)
 (add-to-list 'rainbow-html-colors-major-mode-list 'python-mode)
 :hook ((prog-mode . rainbow-mode)))

(use-package
 highlight-indent-guides
 :init
 (add-hook
  'prog-mode-hook
  (lambda ()
    ;; NOTE: Workaround to fix wired appearance after
    ;; reformatting. See
    ;; https://github.com/DarthFennec/highlight-indent-guides/issues/70#issuecomment-1342713343
    ;; for more information.
    (highlight-indent-guides-mode +1)
    (highlight-indent-guides-mode -1)
    (highlight-indent-guides-mode +1)))
 (setq highlight-indent-guides-method 'character)
 (setq highlight-indent-guides-character ?\┆)
 (setq highlight-indent-guides-responsive 'top))

(use-package
 nyan-mode
 :config (setq nyan-animate-nyancat t) (nyan-mode))

(use-package
 dashboard
 :config (setq dashboard-startup-banner nil)
 (setq dashboard-items
       '((recents . 5)
         (bookmarks . 5)
         (projects . 5)
         (agenda . 5)
         (registers . 5)))
 (when (not command-line-args-left)
   (add-hook
    'after-init-hook
    (lambda ()
      ;; Display useful lists of items
      (dashboard-insert-startupify-lists)))
   (add-hook
    'emacs-startup-hook
    (lambda ()
      (switch-to-buffer "*dashboard*")
      (goto-char (point-min))
      (redisplay)))))

(provide 'setup-appearance)
