(use-package
 org
 :config
 (setq org-hide-leading-stars t)
 (setq org-adapt-indentation t)
 (setq org-default-notes-file (concat org-directory "/notes.org"))
 (setq org-capture-templates
       '(("t"
          "Todo"
          entry
          (file+headline "~/org/todo.org" "Tasks")
          "* TODO %?\n  %i\n  %q")
         ("j"
          "Journal"
          entry
          (file+datetree "~/org/journal.org")
          "* %?\nEntered on %U\n  %i\n  %a")
         ("w"
          "Weekly Sync"
          entry
          (file+datetree "~/org/weekly-sync.org")
          "**** %?")))
 (setq org-html-htmlize-output-type 'css)
 (setq org-html-validation-link nil)
 (org-babel-do-load-languages
  'org-babel-load-languages '((emacs-lisp . t) (shell . t)))

 (with-eval-after-load 'evil-leader
   (evil-leader/set-key
    "oc"
    'org-capture
    "oo"
    'org-open-at-point
    "oe"
    'custom/org-babel-edit:eglot)))

(provide 'setup-org)
