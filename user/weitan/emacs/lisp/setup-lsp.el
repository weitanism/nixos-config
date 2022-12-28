(defconst lsp-client "eglot"
  "Use which lsp client. Choose from [lsp-bridge, lsp-client, eglot]")

;; Performace tuning from lsp-mode doc
;; See https://emacs-lsp.github.io/lsp-mode/page/performance/
(setq gc-cons-threshold (* 100 1024 1024)) ;; 100MB
(setq read-process-output-max (* 1024 1024)) ;; 1MB

;; Web dev things.
(define-derived-mode tsx-mode typescript-mode "TSX")
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-mode))

(use-package
 eslintd-fix
 :hook
 (((tsx-web-mode typescript-mode web-mode)
   .
   custom/enable-eslintd-fix))
 :preface
 (defun custom/locate-npm-executable (name)
   (when buffer-file-name
     (let* ((node-module-path (concat "node_modules/.bin/" name))
            (dir
             (locate-dominating-file
              buffer-file-name node-module-path)))
       (if dir
           (concat dir node-module-path)
         (executable-find name)))))

 (defun custom/set-eslint-executable ()
   (interactive)
   (when-let* ((executable (custom/locate-npm-executable "eslint_d")))
     (setq-local eslintd-fix-executable executable)
     (setq-local flycheck-javascript-eslint-executable executable)))

 (defun custom/enable-eslintd-fix ()
   "Enable eslintd-fix if we're not in node_modules"
   (interactive)
   (when (and buffer-file-name
              (not
               (string-match "\\/node_modules\\/" buffer-file-name)))
     (custom/set-eslint-executable)
     (eslintd-fix-mode))))

(defun setup-python-dev-tools ()
  (add-hook 'python-mode-hook 'blacken-mode)
  (add-hook 'python-mode-hook 'python-isort-on-save-mode)
  (add-hook 'python-mode-hook 'python-autoflake-mode))

(if (string= lsp-client "lsp-bridge")
    (progn
      ;; From https://github.com/manateelazycat/lsp-bridge
      (add-to-list 'load-path "~/.emacs.d/git/lsp-bridge")
      (use-package
       lsp-bridge
       :hook
       (((c-mode c++-mode typescript-mode haskell-mode sh-mode)
         .
         (lambda ()
           (make-local-variable 'evil-lookup-func)
           (setq-local evil-lookup-func
                       'lsp-bridge-popup-documentation))))
       :config
       (setq
        lsp-bridge-get-project-path-by-filepath
        (lambda (filepath)
          (save-match-data
            (or
             (and
              (string-match
               "/home/weitan/workspace/simview/modules/simview/frontend"
               filepath)
              (match-string 0 filepath))
             (and
              (string-match
               "/home/weitan/workspace/ad-cloud/web/regression_pnc_replay"
               filepath)
              (match-string 0 filepath))))))
       (global-lsp-bridge-mode)

       (with-eval-after-load 'evil
         (push '(lambda (string position) (lsp-bridge-find-def))
               evil-goto-definition-functions)
         (evil-define-key
          nil evil-insert-state-map (kbd "C-j") 'acm-select-next)
         (evil-define-key
          nil evil-insert-state-map (kbd "C-k") 'acm-select-prev)
         (evil-define-key
          nil evil-insert-state-map (kbd "TAB") 'acm-complete)
         (evil-define-key
          nil
          evil-normal-state-map
          (kbd "gr")
          'lsp-bridge-find-references)
         (evil-define-key
          'normal
          lsp-bridge-ref-mode-map
          (kbd "q")
          'lsp-bridge-ref-quit)
         (evil-define-key
          'normal
          lsp-bridge-ref-mode-map
          (kbd "RET")
          'lsp-bridge-ref-open-file-and-stay)
         (evil-define-key
          nil evil-normal-state-map (kbd "gd") 'lsp-bridge-find-def)))
      (setup-python-dev-tools)))

(if (string= lsp-client "lsp-client")
    (progn
      (use-package
       company
       :custom
       (company-tooltip-align-annotations t)
       (company-minimum-prefix-length 1)
       :config (add-hook 'after-init-hook 'global-company-mode))
      (use-package
       lsp
       :init
       (setq lsp-lens-enable nil)
       (setq lsp-enable-file-watchers nil)
       (setq lsp-log-io nil) ;; Don't log everything = speed
       :hook
       ((lsp-mode . lsp-enable-which-key-integration)
        (sh-mode . lsp-deferred)
        (nix-mode . lsp-deferred))
       :commands (lsp lsp-deferred))
      (with-eval-after-load 'lsp-mode
        (with-eval-after-load 'evil
          (add-to-list 'lsp-file-watch-ignored-directories "\\.git")
          (add-to-list
           'lsp-file-watch-ignored-directories "\\.ccls-cache")
          (add-to-list
           'lsp-file-watch-ignored-directories "\\.dir-env")
          (add-to-list 'lsp-file-watch-ignored-directories "bazel-.*")
          (evil-define-key
           nil evil-normal-state-map "gr" 'lsp-find-references)
          (evil-define-key
           nil evil-motion-state-map "gr" 'lsp-find-references)
          (lsp-register-client
           (make-lsp-client
            :new-connection
            (lsp-stdio-connection '("rnix-lsp"))
            :major-modes '(nix-mode)
            :server-id 'nix))
          (add-hook 'nix-mode-hook #'lsp-deferred)

          (with-eval-after-load 'evil-leader
            (evil-leader/set-key
             "ld"
             'lsp-bridge-toggle-sdcv-helper
             "lr"
             'lsp-bridge-restart-process
             "=="
             'lsp-bridge-code-format))))
      (use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
      (use-package
       ccls
       :hook ((c-mode c++-mode objc-mode cuda-mode) . lsp-deferred))

      ;; Web development
      (use-package
       tide
       :ensure t
       :after (typescript-mode company flycheck)
       :hook
       ((typescript-mode . tide-hl-identifier-mode)
        (typescript-mode . tide-setup)
        (typescript-mode . lsp-deferred)))
      (use-package
       web-mode
       :init (add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
       :custom
       (web-mode-markup-indent-offset 2)
       (web-mode-css-indent-offset 2)
       (web-mode-code-indent-offset 2)
       (web-mode-enable-auto-pairing t)
       (web-mode-enable-block-face t)
       (web-mode-enable-current-column-highlight t)
       :custom-face
       (web-mode-current-column-highlight-face
        ((t :background "#7a88cf")))
       :hook
       ((web-mode . lsp-deferred)
        (web-mode
         .
         (lambda ()
           (when (string-equal
                  "tsx" (file-name-extension buffer-file-name))
             (setup-tide-mode))))))

      (add-to-list 'warning-suppress-types '(lsp-mode))))

(if (string= lsp-client "eglot")
    (progn
      (use-package
       eglot
       :init
       (add-hook 'eglot-managed-mode-hook #'eldoc-box-hover-mode t)
       (setq eldoc-box-max-pixel-width 1000)
       (setq eldoc-box-max-pixel-height 1200)
       (setq eldoc-box-cleanup-interval 0.1)
       (setq eldoc-echo-area-display-truncation-message nil)
       :hook
       ((sh-mode . eglot-ensure)
        (c-mode . eglot-ensure)
        (c++-mode . eglot-ensure)
        (python-mode . eglot-ensure)
        (typescript-mode . eglot-ensure)
        (js-mode . eglot-ensure)
        (tsx-mode . eglot-ensure)
        (json-mode . eglot-ensure)
        (dockerfile-mode . eglot-ensure)
        (rust-mode . eglot-ensure)
        (haskell-mode . eglot-ensure)
        (yaml-mode . eglot-ensure)
        (nix-mode . eglot-ensure))
       :config
       (add-to-list
        'eglot-server-programs
        '((c-mode c++-mode)
          .
          ;; Appending multiple init params is possible, see
          ;; https://github.com/MaskRay/ccls/commit/c06c2ca3247c196fd396fbf9d1ae4993c5159d5c.
          ("ccls" "--init={\"index\": {\"threads\": 12}}")))
       (put 'tsx-mode 'eglot-language-id "typescriptreact")
       (add-to-list
        'eglot-server-programs
        `(tsx-mode . ("typescript-language-server" "--stdio")))
       (setq eldoc-documentation-strategy
             'eldoc-documentation-compose)
       (with-eval-after-load 'evil
         (evil-define-key
          nil evil-insert-state-map (kbd "C-y") 'yas-insert-snippet)))
      (use-package
       company
       :custom
       (company-tooltip-align-annotations t)
       (company-minimum-prefix-length 1)
       :config (add-hook 'after-init-hook 'global-company-mode))
      (setup-python-dev-tools)
      (evil-leader/set-key "==" 'eglot-format)))

;; Use citre(ctags) when no lsp client enabled. See
;; https://github.com/universal-ctags/citre for more information.
(if (not lsp-client)
    (progn
      (use-package
       citre
       :defer t
       :init
       ;; This is needed in `:init' block for lazy load to work.
       (require 'citre-config)
       ;; Bind your frequently used commands.  Alternatively, you can define them
       ;; in `citre-mode-map' so you can only use them when `citre-mode' is enabled.
       (global-set-key (kbd "C-x c j") 'citre-jump)
       (global-set-key (kbd "C-x c J") 'citre-jump-back)
       (global-set-key (kbd "C-x c p") 'citre-ace-peek)
       (global-set-key (kbd "C-x c u") 'citre-update-this-tags-file)
       :config
       (setq
        citre-project-root-function #'projectile-project-root
        citre-default-create-tags-file-location 'project-cache
        citre-use-project-root-when-creating-tags t
        citre-auto-enable-citre-mode-modes '(prog-mode))
       (setq citre-peek-file-content-height 14)

       (with-eval-after-load 'evil
         (defun custom/smart-citre-peek ()
           (interactive)
           (message "citre-peek--mode: %s" citre-peek--mode)
           (if citre-peek--mode
               (citre-peek-through)
             (citre-peek)))
         (evil-define-key
          nil
          evil-normal-state-map
          (kbd "C-p")
          #'custom/smart-citre-peek)

         (defun custom/smart-citre-ace-peek ()
           (interactive)
           (if citre-peek--mode
               (citre-peek-through)
             (citre-ace-peek)))
         (evil-define-key
          nil
          evil-insert-state-map
          (kbd "C-p")
          #'custom/smart-citre-ace-peek)

         (evil-define-key
          'normal
          citre-peek-keymap
          (kbd "RET")
          #'citre-peek-jump
          (kbd "C-j")
          #'citre-peek-next-tag
          (kbd "C-k")
          #'citre-peek-prev-tag
          (kbd "C-h")
          #'citre-peek-chain-backward
          (kbd "C-l")
          #'citre-peek-chain-forward)
         (evil-define-key
          'insert
          citre-peek-keymap
          (kbd "RET")
          #'citre-peek-jump
          (kbd "C-j")
          #'citre-peek-next-tag
          (kbd "C-k")
          #'citre-peek-prev-tag
          (kbd "C-h")
          #'citre-peek-chain-backward
          (kbd "C-l")
          #'citre-peek-chain-forward)
         (evil-define-minor-mode-key
          'normal citre-peek--mode (kbd "C-p") #'citre-peek-through)
         (add-hook 'citre-mode-hook #'evil-normalize-keymaps)
         (add-hook 'citre-peek--mode-hook #'evil-normalize-keymaps)
         (evil-define-key
          nil evil-insert-state-map (kbd "C-y") 'yas-insert-snippet))

       (defun custom/citre-tags--imenu-tags-from-temp-tags-file ()
         "Get tags for imenu from a new temporary tags file.
If the ctags program is not found, this returns nil."
         (when (citre-executable-find
                (or citre-ctags-program "ctags"))
           (pcase-let* ((`(,cmd . ,cwd)
                         (citre-tags--imenu-ctags-command-cwd))
                        (tags-file
                         (citre-tags--imenu-temp-tags-file-path)))
             (make-directory (file-name-directory tags-file) 'parents)
             (let ((default-directory cwd))
               (apply #'process-file
                      (car cmd)
                      nil
                      (get-buffer-create "*ctags*")
                      nil
                      (cdr cmd)))
             ;; WORKAROUND: If we don't sit for a while, the readtags process will
             ;; freeze.  TOOD: Fix this when uctags offers "edittags" command.
             (sit-for 0.001)
             (unwind-protect
                 (citre-tags-get-tags
                  tags-file
                  nil
                  nil
                  :filter
                  `(not
                    (or ,(citre-readtags-filter
                          'extras
                          '("anonymous" "inputFile")
                          'csv-contain)
                        ,(citre-readtags-filter-kind "file")))
                  :sorter (citre-readtags-sorter 'line)
                  :require '(name pattern)
                  :optional
                  '(ext-kind-full line typeref scope extras))
               (delete-file tags-file)))))
       (advice-add
        'citre-tags--imenu-tags-from-temp-tags-file
        :override #'custom/citre-tags--imenu-tags-from-temp-tags-file))

      (use-package
       company
       :init
       (setq
        company-require-match
        nil ; Don't require match, so you can still move your cursor as expected.
        company-tooltip-align-annotations t ; Align annotation to the right side.
        company-eclim-auto-save nil ; Stop eclim auto save.
        company-dabbrev-downcase nil) ; No downcase when completion.
       :config
       ;; Enable downcase only when completing the completion.
       (defun jcs--company-complete-selection--advice-around (fn)
         "Advice execute around `company-complete-selection' command."
         (let ((company-dabbrev-downcase t))
           (call-interactively fn)))
       (advice-add
        'company-complete-selection
        :around #'jcs--company-complete-selection--advice-around))

      (use-package
       company-fuzzy
       :hook (company-mode . company-fuzzy-mode)
       :init
       (setq
        company-fuzzy-sorting-backend 'flx
        company-fuzzy-prefix-on-top nil
        company-fuzzy-show-annotation t
        company-fuzzy-trigger-symbols '("." "->" "<" "\"" "'" "@")))

      (global-company-mode t)))

(provide 'setup-lsp)
