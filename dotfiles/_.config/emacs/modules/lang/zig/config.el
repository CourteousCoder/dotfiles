;;; lang/zig/config.el -*- lexical-binding: t; -*-

;; DEPRECATED: Remove when projectile is replaced with project.el
(after! projectile
  (add-to-list 'projectile-project-root-files "build.zig"))


;;
;;; Packages

(use-package! zig-mode
  :hook (zig-mode . rainbow-delimiters-mode)
  :config
  (setq zig-format-on-save nil) ; rely on :editor format instead
  (set-formatter! 'zigfmt '("zig" "fmt" "--stdin") :modes '(zig-mode))

  (when (modulep! +lsp)
    (add-hook 'zig-mode-local-vars-hook #'lsp! 'append))

  (when (modulep! +tree-sitter)
    (add-hook 'zig-mode-local-vars-hook #'tree-sitter! 'append))

  (when (modulep! :checkers syntax -flymake)
    (eval '(flycheck-define-checker zig
             "A zig syntax checker using zig's `ast-check` command."
             :command ("zig" "ast-check" (eval (buffer-file-name)))
             :error-patterns
             ((error line-start (file-name) ":" line ":" column ": error: " (message) line-end))
             :modes zig-mode)
          t)
    (add-to-list 'flycheck-checkers 'zig))

  (map! :localleader
        :map zig-mode-map
        "b" #'zig-compile
        "f" #'zig-format-buffer
        "r" #'zig-run
        "t" #'zig-test-buffer))