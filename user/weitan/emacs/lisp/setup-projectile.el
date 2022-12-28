(defun my-projectile-project-find-function (dir)
  (let ((root (projectile-project-root dir)))
    (and root (cons 'transient root))))

(use-package projectile :config (projectile-global-mode))

(use-package
 project
 :config
 (add-to-list
  'project-find-functions 'my-projectile-project-find-function))

(provide 'setup-projectile)
