;; FIXME: Migrate to the builtin tree-sitter.
;; (use-package treesit
;;   :init
;;   (setq-default treesit-font-lock-level 4)
;;   (add-to-list 'major-mode-remap-alist '(c-mode . c-ts-mode))
;;   (add-to-list 'major-mode-remap-alist '(c++-mode . c++-ts-mode))
;;   (add-to-list 'major-mode-remap-alist
;;                '(c-or-c++-mode . c-or-c++-ts-mode)))

(use-package
 tree-sitter
 :init
 (add-hook
  'prog-mode-hook
  (lambda ()
    (turn-on-tree-sitter-mode)
    ;; NOTE: The disabling and re-enabling is a workaround to fix the
    ;; syntax highlighting error when editing.
    (tree-sitter-mode -1)
    (turn-on-tree-sitter-mode)))
 (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))
(use-package tree-sitter-langs)

;; https://github.com/meain/evil-textobj-tree-sitter
(use-package
 evil-textobj-tree-sitter
 :after (evil)
 :init
 ;; bind `function.outer`(entire function block) to `f` for use in things like `vaf`, `yaf`
 (define-key
  evil-outer-text-objects-map
  "f"
  (evil-textobj-tree-sitter-get-textobj "function.outer"))
 ;; bind `function.inner`(function block without name and args) to `f` for use in things like `vif`, `yif`
 (define-key
  evil-inner-text-objects-map
  "f"
  (evil-textobj-tree-sitter-get-textobj "function.inner"))

 (define-key
  evil-outer-text-objects-map
  "l"
  (evil-textobj-tree-sitter-get-textobj "loop.outer"))
 (define-key
  evil-inner-text-objects-map
  "l"
  (evil-textobj-tree-sitter-get-textobj "loop.inner"))

 (define-key
  evil-outer-text-objects-map
  "a"
  (evil-textobj-tree-sitter-get-textobj "parameter.outer"))
 (define-key
  evil-inner-text-objects-map
  "a"
  (evil-textobj-tree-sitter-get-textobj "parameter.inner"))

 ;; Goto start of next function
 (define-key
  evil-normal-state-map (kbd "]f")
  (lambda ()
    (interactive)
    (evil-textobj-tree-sitter-goto-textobj "function.outer")))
 ;; Goto start of previous function
 (define-key
  evil-normal-state-map (kbd "[f")
  (lambda ()
    (interactive)
    (evil-textobj-tree-sitter-goto-textobj "function.outer" t)))
 ;; Goto end of next function
 (define-key
  evil-normal-state-map (kbd "]F")
  (lambda ()
    (interactive)
    (evil-textobj-tree-sitter-goto-textobj "function.outer" nil t)))
 ;; Goto end of previous function
 (define-key
  evil-normal-state-map (kbd "[F")
  (lambda ()
    (interactive)
    (evil-textobj-tree-sitter-goto-textobj "function.outer" t t)))

 ;; Goto next/prev parameter
 (define-key
  evil-normal-state-map (kbd "]a")
  (cons
   "goto-parameter-start"
   (lambda ()
     (interactive)
     (evil-textobj-tree-sitter-goto-textobj "parameter.inner"))))
 (define-key
  evil-normal-state-map (kbd "[a")
  (cons
   "goto-parameter-start"
   (lambda ()
     (interactive)
     (evil-textobj-tree-sitter-goto-textobj "parameter.inner" t))))
 (define-key
  evil-normal-state-map (kbd "]A")
  (cons
   "goto-parameter-end"
   (lambda ()
     (interactive)
     (evil-textobj-tree-sitter-goto-textobj
      "parameter.inner" nil t))))
 (define-key
  evil-normal-state-map (kbd "[A")
  (cons
   "goto-parameter-end"
   (lambda ()
     (interactive)
     (evil-textobj-tree-sitter-goto-textobj "parameter.inner" t t)))))

(use-package
 scopeline
 :after tree-sitter
 :config
 (add-hook 'tree-sitter-mode-hook #'scopeline-mode)
 (setq scopeline-overlay-prefix "  <- ")
 (setq scopeline-min-lines 3)
 (add-to-list
  'scopeline-targets
  '(c++-mode
    "function_definition"
    "for_statement"
    "if_statement"
    "while_statement")))

(use-package
 header-line
 :after tree-sitter
 :config (add-hook 'tree-sitter-mode-hook #'setup-header-line))

;; Copied and modified from
;; https://blog.meain.io/2022/navigating-config-files-using-tree-sitter/
(defun meain/get-config-nesting-paths ()
  "Get out all the nested paths in a config file."
  (let*
      ((query
        (pcase major-mode
          ('json-mode
           "(object (pair (string (string_content) @key) (_)) @item)")
          ('yaml-mode
           "(block_mapping_pair (flow_node) @key (_)) @item")
          ('nix-mode "(binding (attrpath (identifier) @key)) @item")))
       (root-node (tsc-root-node tree-sitter-tree))
       (query (tsc-make-query tree-sitter-language query))
       (matches
        (tsc-query-matches
         query root-node #'tsc--buffer-substring-no-properties))
       (prev-node-ends '(0)) ;; we can get away with just end as the list is sorted
       (current-key-depth '())
       (item-ranges
        (seq-map
         (lambda (x)
           (let ((item (seq-elt (cdr x) 0))
                 (key (seq-elt (cdr x) 1)))
             (list
              (tsc-node-text (cdr key))
              (tsc-node-range (cdr key))
              (tsc-node-range (cdr item)))))
         matches)))
    (mapcar
     (lambda (x)
       (let* ((current-end (seq-elt (cadr (cdr x)) 1))
              (parent-end (car prev-node-ends))
              (current-key (car x)))
         (progn
           (if (> current-end parent-end)
               (mapcar
                (lambda (x)
                  (if (> current-end x)
                      (progn
                        (setq prev-node-ends (cdr prev-node-ends))
                        (setq current-key-depth
                              (cdr current-key-depth)))))
                prev-node-ends))
           (setq current-key-depth
                 (cons current-key current-key-depth))
           (setq prev-node-ends (cons current-end prev-node-ends))
           (list (reverse current-key-depth) (seq-elt (cadr x) 0)))))
     item-ranges)))

(defun meain/goto-config-nesting-path ()
  "Interactively go to a nested path in a config file."
  (interactive)
  (let* ((paths
          (mapcar
           (lambda (x)
             (cons (string-join (car x) ".") (cadr x)))
           (meain/get-config-nesting-paths))))
    (goto-char
     (cdr (assoc (completing-read "Choose path: " paths) paths)))))

(with-eval-after-load 'evil-leader
  (evil-leader/set-key "js" 'meain/goto-config-nesting-path))

(provide 'setup-tree-sitter)
