;;; common-dev-modes.el --- Language modes (Elixir, Python, YAML, Nix, etc.) -*- lexical-binding: t; -*-

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
          (toml "https://github.com/tree-sitter/tree-sitter-toml")
          (yaml "https://github.com/ikatyang/tree-sitter-yaml")
          (json "https://github.com/tree-sitter/tree-sitter-json")
          (nix "https://github.com/nix-community/tree-sitter-nix")))
  (setq major-mode-remap-alist
        '((elixir-mode . elixir-ts-mode)
          (python-mode . python-ts-mode)
          (yaml-mode . yaml-ts-mode)))
  (dolist (grammar treesit-language-source-alist)
    (let ((lang (car grammar)))
      (unless (treesit-language-available-p lang)
        (condition-case err
            (treesit-install-language-grammar lang)
          (error
           (message "Tree-sitter grammar install failed for %s: %s"
                    lang (error-message-string err))))))))

;; LSP via eglot (built-in)
;; Install LSPs:
;;   Elixir: https://github.com/elixir-lang/expert/releases -> ~/.local/bin/expert
;;   Python: pip install pyright
(use-package eglot
  :ensure nil
  :config
  (let ((expert-bin (expand-file-name "~/.local/bin/expert")))
    (when (file-executable-p expert-bin)
      (add-to-list 'eglot-server-programs
                   `(elixir-ts-mode ,expert-bin "--stdio")))))

;; Elixir (formatting handled by apheleia)
(use-package elixir-ts-mode
  :hook (elixir-ts-mode . eglot-ensure))

;; Python (formatting handled by apheleia)
(use-package python
  :ensure nil
  :hook (python-ts-mode . eglot-ensure))

;;; Structural editing (tree-sitter AST)

;; Combobulate provides structural navigation/editing for tree-sitter modes.
;; Only activates in TS-modes; smartparens handles non-TS files.
;; Not on MELPA — pinned via package-vc.
(use-package combobulate
  :vc (:url "https://github.com/mickeynp/combobulate"
       :rev "7fe1ea45ad5fbd798f23b280a8efdb4724b1db38")
  :hook ((elixir-ts-mode    . combobulate-mode)
         (python-ts-mode    . combobulate-mode)
         (yaml-ts-mode      . combobulate-mode)
         (json-ts-mode      . combobulate-mode)
         (nix-ts-mode       . combobulate-mode)
         (toml-ts-mode      . combobulate-mode)
         (dockerfile-ts-mode . combobulate-mode)))

;; Dockerfile
(use-package dockerfile-ts-mode
  :ensure nil
  :mode "\\(?:Dockerfile\\(?:\\..*\\)?\\|\\.[Dd]ockerfile\\)\\'")

;; Markdown
(use-package markdown-mode
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))

(use-package yaml-mode
  :mode (("\\.ya?ml\\'" . yaml-mode)
         ("\\`[Tt]askfile\\'" . yaml-mode)))

;; Nix
(use-package nix-ts-mode
  :mode "\\.nix\\'")

(use-package kubel
  :commands (kubel)
  :config
  (fset 'k8s 'kubel))

(provide 'common-dev-modes)
