;; Copied from https://ox-hugo.scripter.co/doc/org-capture-setup/
(defun org-hugo-new-subtree-post-capture-template ()
  "Returns `org-capture' template string for new Hugo post.
See `org-capture-templates' for more information."
  (let*
      ( ;; http://www.holgerschurig.de/en/emacs-blog-from-org-to-hugo/
       (date
        (format-time-string (org-time-stamp-format :long :inactive)
                            (org-current-time)))
       (title (read-from-minibuffer "Post Title: ")) ;Prompt to enter the post title
       (fname (org-hugo-slug title)))
    (mapconcat
     #'identity
     `(,(concat "* TODO " title)
       ":PROPERTIES:" ,(concat ":EXPORT_FILE_NAME: " fname)
       ,(concat ":EXPORT_DATE: " date) ;Enter current date and time
       ":END:"
       "%?\n") ;Place the cursor here finally
     "\n")))

(use-package
 org
 :config
 (setq org-hide-leading-stars t)
 (setq org-adapt-indentation t)
 (setq org-default-notes-file (concat org-directory "/notes.org"))
 (setq
  org-capture-templates
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
     "**** %?")
    ("b"
     "Blog"
     entry
     ;; It is assumed that below file is present in `org-directory'
     ;; and that it has a "Blog Ideas" heading. It can even be a
     ;; symlink pointing to the actual location of all-posts.org!
     (file+olp "all-posts.org" "Blog Posts")
     (function org-hugo-new-subtree-post-capture-template))))
 (setq org-html-htmlize-output-type 'css)
 (setq org-html-validation-link nil)
 (setq org-image-actual-width nil)
 (org-babel-do-load-languages
  'org-babel-load-languages '((emacs-lisp . t) (shell . t)))

 (use-package ox-hugo :after ox)

 (with-eval-after-load 'evil-leader
   (evil-leader/set-key
    "oc"
    'org-capture
    "oo"
    'org-open-at-point
    "oe"
    'custom/org-babel-edit:eglot)))

(provide 'setup-org)
