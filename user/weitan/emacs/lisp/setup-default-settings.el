(setq quelpa-checkout-melpa-p nil)

;; Load all local variables without the safety prompt
(setq enable-local-variables :all)

;; http://whattheemacsd.com/sane-defaults.el-01.html
;; Auto refresh buffers
(global-auto-revert-mode 1)
;; Also auto refresh dired, but be quiet about it
(setq global-auto-revert-non-file-buffers t)
(setq auto-revert-verbose nil)

;; Improve dired default settings.
(setq dired-dwim-target t)
(setq dired-listing-switches "-alh")

;; Hide menubar, toolbar and scrollbar.
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Make scrolling smoother.
(pixel-scroll-precision-mode)

(setq-default frame-title-format '("%b - GNU Emacs"))

;; Show column number under cursor.
(column-number-mode)

;; Make `split-window-sensibly` always split window to right.
(setq split-height-threshold nil)
(setq split-width-threshold 0)

(setq-default indent-tabs-mode nil)

;; Put autosave files (ie #foo#) and backup files (ie foo~) in
;; ~/.emacs.d/autosaves/.
(setq auto-save-file-name-transforms
      '((".*" "~/.emacs.d/autosaves/\\1" t)))
(make-directory "~/.emacs.d/autosaves/" t)

(setq backup-directory-alist '((".*" . "~/.emacs.d/backups/")))

(provide 'setup-default-settings)
