;; Treesitter
;; Both GUI app and Homebrew CLI must be the same Emacs version to avoid
;; tree-sitter ABI mismatches when compiling grammars.
(use-package emacs
  :ensure nil
  :config
  (setq treesit-language-source-alist
        '((heex "https://github.com/phoenixframework/tree-sitter-heex")
          (elixir "https://github.com/elixir-lang/tree-sitter-elixir")
          (python "https://github.com/tree-sitter/tree-sitter-python")
          (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile")
          (toml "https://github.com/tree-sitter/tree-sitter-toml")))
  (setq major-mode-remap-alist
        '((elixir-mode . elixir-ts-mode)
          (python-mode . python-ts-mode)))
  (dolist (grammar treesit-language-source-alist)
    (unless (treesit-language-available-p (car grammar))
      (treesit-install-language-grammar (car grammar)))))

;; LSP via eglot (built-in)
;; Install LSPs:
;;   Elixir: https://github.com/elixir-lang/expert/releases -> ~/.local/bin/expert
;;   Python: pip install pyright
(use-package eglot
  :ensure nil
  :config
  (add-to-list 'eglot-server-programs
               `(elixir-ts-mode ,(expand-file-name "~/.local/bin/expert") "--stdio")))

;; Elixir
(use-package elixir-ts-mode
  :hook (elixir-ts-mode . eglot-ensure)
  :hook (elixir-ts-mode . (lambda () (add-hook 'before-save-hook #'eglot-format nil t))))

;; Python
(use-package python
  :ensure nil
  :hook (python-ts-mode . eglot-ensure)
  :hook (python-ts-mode . (lambda () (add-hook 'before-save-hook #'eglot-format nil t))))

;; Dockerfile
(use-package dockerfile-ts-mode
  :ensure nil
  :mode "\\(?:Dockerfile\\(?:\\..*\\)?\\|\\.[Dd]ockerfile\\)\\'")

;; Markdown
(use-package markdown-mode
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))

(use-package yaml-mode
  :mode "\\.ya?ml\\'")

(use-package kubel
  :commands (kubel)
  :config
  (fset 'k8s 'kubel))
