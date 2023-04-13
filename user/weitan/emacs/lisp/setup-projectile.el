(defun my-projectile-project-find-function (dir)
  (let ((root (projectile-project-root dir)))
    (and root (cons 'transient root))))

(use-package projectile :config (projectile-global-mode))

(use-package
 project
 :config
 (add-to-list
  'project-find-functions 'my-projectile-project-find-function)

 ;; Move `bazel-find-project' to the front of
 ;; `project-find-functions'.
 (delete 'bazel-find-project project-find-functions)
 (add-to-list 'project-find-functions 'bazel-find-project))

(provide 'setup-projectile)
