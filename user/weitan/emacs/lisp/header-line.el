;; Header line faces
(defface header-line-face-default nil
  "Header line default face"
  :group 'header)

(defface header-line-face-file-status nil
  "Header line face for which function"
  :group 'header)

(defface header-line-face-file-path nil
  "Header line face for which function"
  :group 'header)

(defface header-line-face-location nil
  "Header line face for which function"
  :group 'header)

(set-face-attribute 'header-line-face-default nil
                    :background "#444444"
                    :inherit 'mode-line)

(set-face-attribute 'header-line-face-file-status nil
                    :inherit 'header-line-face-default
                    :bold t
                    :foreground "#fe8019")

(set-face-attribute 'header-line-face-file-path nil
                    :bold t
                    :inherit 'header-line-face-default)

(set-face-attribute 'header-line-face-location nil
                    :inherit 'header-line-face-default
                    :bold t
                    :italic t
                    :foreground "#83a598")

;; Tree-sitter related utils.
(defun header-line/tree-sitter-collect-ancestors
    (ancestor-type &optional node ancestors)
  (let* ((node (or node (tree-sitter-node-at-point ancestor-type)))
         (ancestors (or ancestors '()))
         (ancestors
          (if (and node (eq (tsc-node-type node) ancestor-type))
              (append (list node) ancestors)
            ancestors))
         (parent-node (and node (tsc-get-parent node))))
    (if (not parent-node)
        ancestors
      (header-line/tree-sitter-collect-ancestors ancestor-type
                                                 parent-node
                                                 ancestors))))

(defun header-line/tree-sitter-get-child-with-type--helper
    (current-node target-child-type &optional offset count)
  (and current-node
       (let* ((children-count
               (or count (tsc-count-children current-node)))
              (test-offset (or offset 0)))
         (if (>= test-offset children-count)
             nil
           (let* ((child-node
                   (tsc-get-nth-child current-node test-offset))
                  (child-node-type (tsc-node-type child-node)))
             (if (eq child-node-type target-child-type)
                 child-node
               (header-line/tree-sitter-get-child-with-type--helper
                current-node target-child-type
                (+ test-offset 1) children-count)))))))

(defun header-line/tree-sitter-get-child-with-type
    (current-node target-child-type &rest types)
  (let ((child-node
         (header-line/tree-sitter-get-child-with-type--helper
          current-node target-child-type)))
    (if (> (length types) 0)
        (and child-node
             (let ((args (append (list child-node) types)))
               (apply 'header-line/tree-sitter-get-child-with-type
                      args)))
      child-node)))

(defun header-line/tsc-node-text (node &optional fallback)
  (or (and node (tsc-node-text node)) (or fallback nil)))
(defun header-line/tsc-node-text-oneline (node &optional fallback)
  (let ((text (header-line/tsc-node-text node fallback)))
    (and text
         (s-replace-regexp " +" " " (string-replace "\n" " " text)))))

;; C++
(defun
    header-line/tree-sitter-get-current-location-namespace--c++-mode
    ()
  (let ((namespaces
         (header-line/tree-sitter-collect-ancestors
          'namespace_definition)))
    (if (> (length namespaces) 0)
        (mapconcat '(lambda (namespace-node)
                      (header-line/tsc-node-text
                       (header-line/tree-sitter-get-child-with-type
                        namespace-node 'identifier)
                       "UNAMED"))
                   namespaces
                   "::")
      nil)))
(defun header-line/tree-sitter-get-current-location-class--c++-mode ()
  (let ((class-node (tree-sitter-node-at-point 'class_specifier)))
    (and class-node
         (header-line/tsc-node-text
          (header-line/tree-sitter-get-child-with-type
           class-node 'type_identifier)))))
(defun header-line/tree-sitter-get-current-location-function--c++-mode
    ()
  (let* ((function-definition-node
          (tree-sitter-node-at-point 'function_definition))
         (function-declarator-node
          (header-line/tree-sitter-get-child-with-type
           function-definition-node 'function_declarator))
         (function-declarator-node
          (or function-declarator-node
              (header-line/tree-sitter-get-child-with-type
               function-definition-node 'reference_declarator
               'function_declarator))))
    (and function-declarator-node
         (header-line/tsc-node-text
          (or (header-line/tree-sitter-get-child-with-type
               function-declarator-node 'qualified_identifier)
              (header-line/tree-sitter-get-child-with-type
               function-declarator-node 'field_identifier)
              (header-line/tree-sitter-get-child-with-type
               function-declarator-node 'identifier))))))

;; Copied from https://blog.meain.io/2022/navigating-config-files-using-tree-sitter.
(defun meain/tree-sitter-config-nesting ()
  (if (or (eq major-mode 'json-mode)
          (eq major-mode 'yaml-mode)
          (eq major-mode 'nix-mode))
      (let*
          ((cur-point (point))
           (query
            (pcase major-mode
              ('json-mode
               "(object (pair (string (string_content) @key) (_)) @item)")
              ('yaml-mode
               "(block_mapping_pair (flow_node) @key (_)) @item")
              ('nix-mode
               "(binding (attrpath (identifier) @key)) @item")))
           (root-node (tsc-root-node tree-sitter-tree))
           (query (tsc-make-query tree-sitter-language query))
           (matches
            (tsc-query-matches
             query root-node #'tsc--buffer-substring-no-properties)))
        (string-join (remove-if
                      (lambda (x) (eq x nil))
                      (seq-map
                       (lambda (x)
                         (let ((item (seq-elt (cdr x) 0))
                               (key (seq-elt (cdr x) 1)))
                           (if (and (> cur-point
                                       (byte-to-position
                                        (car
                                         (tsc-node-byte-range
                                          (cdr item)))))
                                    (< cur-point
                                       (byte-to-position
                                        (cdr
                                         (tsc-node-byte-range
                                          (cdr item))))))
                               (format "%s" (tsc-node-text (cdr key)))
                             nil)))
                       matches))
                     "."))))

;; YAML
(defun
    header-line/tree-sitter-get-current-location-namespace--yaml-mode
    ()
  (meain/tree-sitter-config-nesting))

;; JSON
(defun
    header-line/tree-sitter-get-current-location-namespace--json-mode
    ()
  (meain/tree-sitter-config-nesting))

;; Nix
(defun
    header-line/tree-sitter-get-current-location-namespace--nix-mode
    ()
  (let ((path (meain/tree-sitter-config-nesting)))
    (if (eq path "")
        nil
      path)))

(defun header-line/invoke-function (function-name)
  (let ((function (intern function-name)))
    (if (fboundp function)
        (funcall function)
      nil)))

(defun header-line/tree-sitter-get-current-location ()
  (let* ((namespace-getter-name
          (concat
           "header-line/tree-sitter-get-current-location-namespace--"
           (symbol-name major-mode)))
         (class-getter-name
          (concat
           "header-line/tree-sitter-get-current-location-class--"
           (symbol-name major-mode)))
         (function-getter-name
          (concat
           "header-line/tree-sitter-get-current-location-function--"
           (symbol-name major-mode)))
         (namespace
          (header-line/invoke-function namespace-getter-name))
         (class (header-line/invoke-function class-getter-name))
         (function
          (header-line/invoke-function function-getter-name)))
    (let ((items
           (seq-filter
            (lambda (x) x) (list namespace class function))))
      (and (> (length items) 0)
           (mapconcat (lambda (x) x) items "::")))))

(defun header-line/prog-mode-p ()
  (derived-mode-p 'prog-mode))

(defun header-line/compose (status path location)
  "Compose a string with provided information"
  (let* ((char-width (window-font-width nil 'header-line))
         (window (get-buffer-window (current-buffer)))
         (space-up +0.20)
         (space-down -0.10)
         (location
          (if location
              (concat "=> " location)
            ""))
         (left
          (concat
           (propertize " "
                       'face
                       'header-line-face-default
                       'display
                       `(raise ,space-up))
           ;; (propertize path 'face 'header-line-face-file-path)
           (propertize location 'face 'header-line-face-location)
           (propertize " "
                       'face
                       'header-line-face-default
                       'display
                       `(raise ,space-down))))
         (right
          (concat
           (propertize (if (window-dedicated-p)
                           "-- "
                         (concat "" status " "))
                       'face 'header-line-face-file-status)
           ;; (propertize location 'face 'header-line-face-location)
           ))
         (char-width
          (window-font-width nil 'header-line-face-default))
         (available-width
          (- (window-total-width) (length left)
             (length right)
             (/ (window-right-divider-width) char-width)))
         (spacer
          (propertize (make-string available-width ?\ )
                      'face
                      'header-line-face-default)))
    (concat left spacer right)))

(defun header-line/buffer-status ()
  "Return buffer status: read-only (RO), modified (**) or read-write (RW)"
  (let ((read-only buffer-read-only)
        (modified (and buffer-file-name (buffer-modified-p))))
    (cond
     (modified
      "**")
     (read-only
      "RO")
     (t
      "RW"))))

(defun header-line/default-mode ()
  (let* ((path (or (spacemacs--projectile-file-path) (buffer-name)))
         (location (header-line/tree-sitter-get-current-location)))
    (header-line/compose
     (ignore-errors
       (header-line/buffer-status)
       path
       location))))

(defun setup-header-line ()
  "Install a header line whose content is dependend on the major mode"
  (interactive)
  (setq-local header-line-format
              '((:eval
                 (cond
                  ((header-line/prog-mode-p)
                   (header-line/default-mode))
                  (t
                   (header-line/default-mode)))))))

(provide 'header-line)
