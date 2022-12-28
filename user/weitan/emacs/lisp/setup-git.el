(use-package
 magit
 :after (evil-leader)
 :config (setq magit-diff-refine-hunk t)

 ;; Integrate difftastic into magit. Copied from
 ;; https://tsdh.org/posts/2022-08-01-difftastic-diffing-with-magit.html.
 (transient-define-prefix
  custom/magit-aux-commands () "My personal auxiliary magit commands."
  ["Auxiliary commands" ("d"
    "Difftastic Diff (dwim)"
    custom/magit-diff-with-difftastic)
   ("s" "Difftastic Show" custom/magit-show-with-difftastic)])
 (transient-append-suffix
  'magit-dispatch "!"
  '("#" "My Magit Commands" custom/magit-aux-commands))
 (define-key
  magit-status-mode-map (kbd "#") #'custom/magit-aux-commands)

 (evil-leader/set-key "gs" 'magit-status "gl" 'magit-log-buffer-file))

(defun custom/blamer-show-commit-info ()
  (interactive)
  (let* ((char-width
          (window-font-width nil 'blamer-pretty-commit-message-face))
         (buffer-width 5)
         (offset
          (save-excursion
            (evil-first-non-blank)
            (current-column)))
         (available-width
          (- (window-total-width)
             (/ (window-right-divider-width) char-width)
             offset
             buffer-width))
         (blamer-max-commit-message-length (min available-width 150)))
    (blamer-show-commit-info)))

(use-package
 blamer
 :bind (("s-i" . custom/blamer-show-commit-info))
 :defer 20
 :custom
 (blamer-idle-time 0.5)
 (blamer-min-offset 50)
 (blamer-max-commit-message-length 60)
 (blamer-type 'visual)
 :custom-face
 (blamer-face
  ((t :foreground "#7a88cf" :background nil :height 140 :italic t)))
 :config (global-blamer-mode 1))

(with-eval-after-load 'git-rebase
  (define-key
   git-rebase-mode-map (kbd "C-k") 'git-rebase-move-line-up)
  (define-key
   git-rebase-mode-map (kbd "C-j") 'git-rebase-move-line-down))

(use-package
 diff-hl
 :config
 (global-diff-hl-mode)
 (diff-hl-flydiff-mode)
 (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
 (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))

(use-package forge :after magit)

(use-package code-review)

(provide 'setup-git)
