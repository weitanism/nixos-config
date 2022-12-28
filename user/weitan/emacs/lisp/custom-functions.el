;; ----------------
;; Custom functions
;; ----------------

(defvar killed-file-list nil
  "List of recently killed files.")

(defun add-file-to-killed-file-list ()
  "If buffer is associated with a file name, add that file to the
`killed-file-list' when killing the buffer."
  (when buffer-file-name
    (push buffer-file-name killed-file-list)))

(defun reopen-killed-file ()
  "Reopen the most recently killed file, if one exists."
  (interactive)
  (when killed-file-list
    (find-file (pop killed-file-list))))

(defun ivy-with-thing-at-point (cmd &optional dir)
  (let ((ivy-initial-inputs-alist
         (list (cons cmd (thing-at-point 'symbol)))))
    (funcall cmd nil dir)))

(defun counsel-projectile-rg-thing-at-point ()
  (interactive)
  (ivy-with-thing-at-point 'counsel-rg))

(defun delete-current-buffer-file ()
  "Removes file connected to current buffer and kills buffer."
  (interactive)
  (let ((filename (buffer-file-name))
        (buffer (current-buffer))
        (name (buffer-name)))
    (if (not (and filename (file-exists-p filename)))
        (ido-kill-buffer)
      (if (yes-or-no-p
           (format "Are you sure you want to delete this file: '%s'?"
                   name))
          (progn
            (delete-file filename t)
            (kill-buffer buffer)
            (when (projectile-project-p)
              (call-interactively #'projectile-invalidate-cache))
            (message "File deleted: '%s'" filename))
        (message "Canceled: File deletion")))))

(defun counsel-rg-at (dir)
  (counsel-rg "" dir))

(defun counsel-rg-at-interactive-dir ()
  (interactive)
  (counsel--find-file-1
   "Search in: " nil #'counsel-rg-at 'counsel-find-file))

(defun reload-config ()
  (interactive)
  (load-file "~/.emacs.d/init.el"))

(defun save-all ()
  (interactive)
  (save-some-buffers t))

(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  ;; company is an optional dependency. You have to
  ;; install it separately via package-install
  ;; `M-x package-install [ret] company`
  (company-mode +1))

(defun spacemacs/toggle-maximize-buffer ()
  "Maximize buffer"
  (interactive)
  (save-excursion
    (if (and (= 1 (length (window-list))) (assoc ?_ register-alist))
        (jump-to-register ?_)
      (progn
        (window-configuration-to-register ?_)
        (delete-other-windows)))))

(defun spacemacs/save-as (filename &optional visit)
  "Save current buffer or active region as specified file.
When called interactively, it first prompts for FILENAME, and then asks
whether to VISIT it, and if so, whether to show it in current window or
another window. When prefixed with a universal-argument \\[universal-argument], include
filename in prompt.

FILENAME  a non-empty string as the name of the saved file.
VISIT     When it's `:current', open FILENAME in current window. When it's
          `:other', open FILENAME in another window. When it's nil, only
          save to FILENAME but does not visit it. (Default to `:current'
          when called from a LISP program.)

When FILENAME already exists, it also asks the user whether to
overwrite it."
  (interactive (let* ((filename
                       (expand-file-name
                        (read-file-name "Save buffer as: "
                                        nil nil nil
                                        (when current-prefix-arg
                                          (buffer-name)))))
                      (choices
                       '("Current window"
                         "Other window"
                         "Don't open"))
                      (actions '(:current :other nil))
                      (visit
                       (let ((completion-ignore-case t))
                         (nth
                          (cl-position
                           (completing-read
                            "Do you want to open the file? " choices
                            nil t)
                           choices
                           :test #'equal)
                          actions))))
                 (list filename visit)))
  (unless (called-interactively-p 'any)
    (cl-assert
     (and (stringp filename)
          (not (string-empty-p filename))
          (not (directory-name-p filename)))
     t "Expect a non-empty filepath, found: %s")
    (setq
     filename (expand-file-name filename)
     visit (or visit :other))
    (let ((choices '(:current :other nil)))
      (cl-assert
       (memq visit choices) t "Found %s, expect one of %s")))
  (let ((dir (file-name-directory filename)))
    (unless (file-directory-p dir)
      (make-directory dir t)))
  (if (use-region-p)
      (write-region (region-beginning) (region-end) filename
                    nil
                    nil
                    nil
                    t)
    (write-region nil nil filename nil nil nil t))
  (pcase visit
    (:current (find-file filename))
    (:other
     (funcall-interactively 'find-file-other-window filename))))

(defun spacemacs/rename-current-buffer-file (&optional arg)
  "Rename the current buffer and the file it is visiting.
If the buffer isn't visiting a file, ask if it should
be saved to a file, or just renamed.

If called without a prefix argument, the prompt is
initialized with the current directory instead of filename."
  (interactive "P")
  (let ((file (buffer-file-name)))
    (if (and file (file-exists-p file))
        (spacemacs/rename-buffer-visiting-a-file arg)
      (spacemacs/rename-buffer-or-save-new-file))))

(defun spacemacs/rename-buffer-visiting-a-file (&optional arg)
  (let* ((old-filename (buffer-file-name))
         (old-short-name (file-name-nondirectory (buffer-file-name)))
         (old-dir (file-name-directory old-filename))
         (new-name
          (let ((path
                 (read-file-name "New name: "
                                 (if arg
                                     old-dir
                                   old-filename))))
            (if (string= (file-name-nondirectory path) "")
                (concat path old-short-name)
              path)))
         (new-dir (file-name-directory new-name))
         (new-short-name (file-name-nondirectory new-name))
         (file-moved-p (not (string-equal new-dir old-dir)))
         (file-renamed-p
          (not (string-equal new-short-name old-short-name))))
    (cond
     ((get-buffer new-name)
      (error "A buffer named '%s' already exists!" new-name))
     ((string-equal new-name old-filename)
      (spacemacs/show-hide-helm-or-ivy-prompt-msg
       "Rename failed! Same new and old name" 1.5)
      (spacemacs/rename-current-buffer-file))
     (t
      (let ((old-directory (file-name-directory new-name)))
        (when (and (not (file-exists-p old-directory))
                   (yes-or-no-p
                    (format "Create directory '%s'?" old-directory)))
          (make-directory old-directory t)))
      (rename-file old-filename new-name 1)
      (rename-buffer new-name)
      (set-visited-file-name new-name)
      (set-buffer-modified-p nil)
      (when (fboundp 'recentf-add-file)
        (recentf-add-file new-name)
        (recentf-remove-if-non-kept old-filename))
      (when (projectile-project-p)
        (funcall #'projectile-invalidate-cache nil))
      (message
       (cond
        ((and file-moved-p file-renamed-p)
         (concat
          "File Moved & Renamed\n"
          "From: "
          old-filename
          "\n"
          "To:   "
          new-name))
        (file-moved-p
         (concat
          "File Moved\n"
          "From: "
          old-filename
          "\n"
          "To:   "
          new-name))
        (file-renamed-p
         (concat
          "File Renamed\n"
          "From: "
          old-short-name
          "\n"
          "To:   "
          new-short-name))))))))

(defun spacemacs/show-hide-helm-or-ivy-prompt-msg (msg sec)
  "Show a MSG at the helm or ivy prompt for SEC.
With Helm, remember the path, then restore it after SEC.
With Ivy, the path isn't editable, just remove the MSG after SEC."
  (run-at-time 0 nil
               #'(lambda (msg sec)
                   (let* ((prev-prompt-contents
                           (buffer-substring
                            (line-beginning-position)
                            (line-end-position)))
                          (prev-prompt-contents-p
                           (not (string= prev-prompt-contents "")))
                          (helmp (fboundp 'helm-mode)))
                     (when prev-prompt-contents-p
                       (delete-region
                        (line-beginning-position)
                        (line-end-position)))
                     (insert (propertize msg 'face 'warning))
                     ;; stop checking for candidates
                     ;; and update the helm prompt
                     (when helmp
                       (helm-suspend-update t))
                     (sit-for sec)
                     (delete-region
                      (line-beginning-position) (line-end-position))
                     (when prev-prompt-contents-p
                       (insert prev-prompt-contents)
                       ;; start checking for candidates
                       ;; and update the helm prompt
                       (when helmp
                         (helm-suspend-update nil)))))
               msg sec))

(defun spacemacs/rename-buffer-or-save-new-file ()
  (let ((old-short-name (buffer-name))
        key)
    (while (not (memq key '(?s ?r)))
      (setq key
            (read-key
             (propertize
              (format (concat
                       "Buffer '%s' is not visiting a file: "
                       "[s]ave to file or [r]ename buffer?")
                      old-short-name)
              'face 'minibuffer-prompt)))
      (cond
       ((eq key ?s) ; save to file
        ;; this allows for saving a new empty (unmodified) buffer
        (unless (buffer-modified-p)
          (set-buffer-modified-p t))
        (save-buffer))
       ((eq key ?r) ; rename buffer
        (let ((new-buffer-name (read-string "New buffer name: ")))
          (while (get-buffer new-buffer-name)
            ;; ask to rename again, if the new buffer name exists
            (if (yes-or-no-p
                 (format (concat
                          "A buffer named '%s' already exists: "
                          "Rename again?")
                         new-buffer-name))
                (setq new-buffer-name
                      (read-string "New buffer name: "))
              (keyboard-quit)))
          (rename-buffer new-buffer-name)
          (message
           (concat
            "Buffer Renamed\n"
            "From: "
            old-short-name
            "\n"
            "To:   "
            new-buffer-name))))
       ;; ?\a = C-g, ?\e = Esc and C-[
       ((memq key '(?\a ?\e))
        (keyboard-quit))))))

(defun spacemacs--projectile-file-path ()
  "Retrieve the file path relative to project root.

Returns:
  - A string containing the file path in case of success.
  - `nil' in case the current buffer does not visit a file."
  (when-let (file-name
             (buffer-file-name))
    (file-relative-name (file-truename file-name)
                        (projectile-project-root))))

(defun spacemacs/projectile-copy-file-path ()
  "Copy and show the file path relative to project root."
  (interactive)
  (if-let (file-path
           (spacemacs--projectile-file-path))
    (progn
      (kill-new file-path)
      (message "%s" file-path))
    (message "WARNING: Current buffer is not visiting a file!")))

(defun open-shellcheck-wiki-at-point ()
  (interactive)
  (-when-let*
      ((first-error
        ;; Get the first error at point that has an `error-explainer'.
        (seq-find
         (lambda (error)
           (flycheck-checker-get
            (flycheck-error-checker error) 'error-explainer))
         (flycheck-overlay-errors-at (point))))
       (explainer
        (flycheck-checker-get
         (flycheck-error-checker first-error) 'error-explainer))
       (explanation (funcall explainer first-error))
       (code (car (s-split ":" explanation)))
       (wiki-url (concat "https://www.shellcheck.net/wiki/" code)))
    (shell-command (concat "xdg-open " wiki-url))))

(defun spacemacs/kill-this-buffer (&optional arg)
  "Kill the current buffer.
If the universal prefix argument is used then kill also the window."
  (interactive "P")
  (if (window-minibuffer-p)
      (abort-recursive-edit)
    (if (equal '(4) arg)
        (kill-buffer-and-window)
      (kill-buffer))))

(defun show-magit-only ()
  (interactive)
  (magit-status)
  (delete-other-windows))

;; Modified from mbarton98's snippet:
;; https://github.com/joaotavora/eglot/issues/216#issuecomment-1052931508
(defun custom/org-babel-edit:eglot ()
  "Edit src block with eglot support by tangling the block and
then setting the org-edit-special buffer-file-name to the
absolute path. Finally load eglot."
  (interactive)

  ;; org-babel-get-src-block-info returns lang, code_src, and header
  ;; params; Use nth 2 to get the params and then retrieve the :tangle
  ;; to get the filename
  (setq mb/tangled-file-name
        (expand-file-name
         (assoc-default
          :tangle (nth 2 (org-babel-get-src-block-info)))))

  ;; tangle the src block at point
  (org-babel-tangle '(4))
  (org-edit-special)

  ;; Now we should be in the special edit buffer with eglot. Set
  ;; the buffer-file-name to the tangled file so that pylsp and
  ;; plugins can see an actual file.
  (setq-local buffer-file-name mb/tangled-file-name)
  (eglot-ensure))

(defun python-remove-unused-imports ()
  "Use Autoflake to remove unused function.
$ autoflake --remove-all-unused-imports -i unused_imports.py"
  (interactive)
  (let ((autoflake-path (executable-find "autoflake")))
    (if autoflake-path
        (let ((tmp-file "/tmp/autoflake-tmp-file"))
          (save-excursion
            (write-region (point-min) (point-max) tmp-file)
            (shell-command
             (format "%s --remove-all-unused-imports -i %s"
                     autoflake-path tmp-file))
            (insert-file-contents tmp-file nil nil nil t)))
      (message "error: Can not find autoflake executable!"))))

(defun python-autoflake-mode ()
  (add-hook 'before-save-hook 'python-remove-unused-imports nil t))

(defun custom/magit--with-difftastic (buffer command)
  "Run COMMAND with GIT_EXTERNAL_DIFF=difft then show result in BUFFER."
  (let ((process-environment
         (cons
          (concat
           "GIT_EXTERNAL_DIFF=difft --width="
           (number-to-string (frame-width)))
          process-environment)))
    ;; Clear the result buffer (we might regenerate a diff, e.g., for
    ;; the current changes in our working directory).
    (with-current-buffer buffer
      (setq buffer-read-only nil)
      (erase-buffer))
    ;; Now spawn a process calling the git COMMAND.
    (make-process
     :name (buffer-name buffer)
     :buffer buffer
     :command command
     ;; Don't query for running processes when emacs is quit.
     :noquery t
     ;; Show the result buffer once the process has finished.
     :sentinel
     (lambda (proc event)
       (when (eq (process-status proc) 'exit)
         (with-current-buffer (process-buffer proc)
           (goto-char (point-min))
           (ansi-color-apply-on-region (point-min) (point-max))
           (setq buffer-read-only t)
           (view-mode)
           (end-of-line)
           ;; difftastic diffs are usually 2-column side-by-side,
           ;; so ensure our window is wide enough.
           (let ((width (current-column)))
             (while (zerop (forward-line 1))
               (end-of-line)
               (setq width (max (current-column) width)))
             ;; Add column size of fringes
             (setq width
                   (+ width (fringe-columns 'left)
                      (fringe-columns 'right)))
             (goto-char (point-min))
             (pop-to-buffer
              (current-buffer)
              `( ;; If the buffer is that wide that splitting the frame in
                ;; two side-by-side windows would result in less than
                ;; 80 columns left, ensure it's shown at the bottom.
                ,(when (> 80 (- (frame-width) width))
                   #'display-buffer-at-bottom)
                (window-width . ,(min width (frame-width))))))))))))

(defun custom/magit-show-with-difftastic (rev)
  "Show the result of \"git show REV\" with GIT_EXTERNAL_DIFF=difft."
  (interactive
   (list
    (or
     ;; If REV is given, just use it.
     (when (boundp 'rev)
       rev)
     ;; If not invoked with prefix arg, try to guess the REV from
     ;; point's position.
     (and (not current-prefix-arg)
          (or (magit-thing-at-point 'git-revision t)
              (magit-branch-or-commit-at-point)))
     ;; Otherwise, query the user.
     (magit-read-branch-or-commit "Revision"))))
  (if (not rev)
      (error "No revision specified")
    (custom/magit--with-difftastic
     (get-buffer-create (concat "*git show difftastic " rev "*"))
     (list "git" "--no-pager" "show" "--ext-diff" rev))))

(defun custom/magit-diff-with-difftastic (arg)
  "Show the result of \"git diff ARG\" with GIT_EXTERNAL_DIFF=difft."
  (interactive
   (list
    (or
     ;; If RANGE is given, just use it.
     (when (boundp 'range)
       range)
     ;; If prefix arg is given, query the user.
     (and current-prefix-arg
          (magit-diff-read-range-or-commit "Range"))
     ;; Otherwise, auto-guess based on position of point, e.g., based on
     ;; if we are in the Staged or Unstaged section.
     (pcase (magit-diff--dwim)
       ('unmerged (error "unmerged is not yet implemented"))
       ('unstaged nil)
       ('staged "--cached")
       (`(stash . ,value) (error "stash is not yet implemented"))
       (`(commit . ,value) (format "%s^..%s" value value))
       ((and range (pred stringp)) range)
       (_ (magit-diff-read-range-or-commit "Range/Commit"))))))
  (let ((name
         (concat
          "*git diff difftastic"
          (if arg
              (concat " " arg)
            "")
          "*")))
    (custom/magit--with-difftastic
     (get-buffer-create name)
     `("git" "--no-pager" "diff" "--ext-diff" ,@
       (when arg
         (list arg))))))

(provide 'custom-functions)
