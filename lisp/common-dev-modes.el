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
          (nix "https://github.com/nix-community/tree-sitter-nix")
          (hcl "https://github.com/MichaHoffmann/tree-sitter-hcl")))
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
                   `(elixir-ts-mode ,expert-bin "--stdio"))))
  (let ((terraform-ls-bin (executable-find "terraform-ls")))
    (when terraform-ls-bin
      (add-to-list 'eglot-server-programs
                   `(terraform-mode ,terraform-ls-bin "serve")))))

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

;;; Terraform
;; Classic terraform-mode (MELPA).  Emacs 30 has no hcl-ts-mode yet; the HCL
;; tree-sitter grammar is still installed above for future migration.
;; Apheleia ships a `terraform' formatter and a `terraform-mode' mode-alist
;; entry, so `terraform fmt' on save works out of the box when the
;; `terraform' CLI is on PATH.
(use-package terraform-mode
  :mode ("\\.tf\\'" "\\.tfvars\\'")
  :hook (terraform-mode . eglot-ensure))

;; Markdown
(use-package markdown-mode
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))

(use-package yaml-mode
  :mode (("\\.ya?ml\\'" . yaml-mode)
         ("\\`[Tt]askfile\\'" . yaml-mode)))

;;; Ansible
;; Auto-detect Ansible files by path and enable the `ansible' minor-mode
;; on top of yaml-ts-mode.  Matches common layouts:
;;   - roles/<name>/{tasks,handlers,vars,defaults,meta}/*.yml
;;   - group_vars/*, host_vars/*, inventory/*
;;   - playbook*.yml, site.yml
(defvar my/ansible-file-regexp
  (rx (or (: "roles/" (+ (not (any ?/))) "/"
             (or "tasks" "handlers" "vars" "defaults" "meta") "/"
             (+ anychar) ".y" (? "a") "ml")
          (: (or "group_vars" "host_vars" "inventory") "/"
             (+ anychar) ".y" (? "a") "ml")
          (: (or "playbook" "site") (* anychar) ".y" (? "a") "ml"))
      eos)
  "Regexp matching typical Ansible YAML paths.")

;; Private: consulted by the yaml-ts-mode hook; no @doc per project convention.
(defun my/ansible-maybe-enable ()
  (when (and buffer-file-name
             (string-match-p my/ansible-file-regexp buffer-file-name))
    (ansible 1)))

(use-package ansible
  :commands (ansible)
  :hook (yaml-ts-mode . my/ansible-maybe-enable))

;;; Jinja2 templates (used by Ansible, Salt, Flask, ...)
(use-package jinja2-mode
  :mode ("\\.j2\\'" "\\.jinja2\\'"))

;; Nix
(use-package nix-ts-mode
  :mode "\\.nix\\'")

(use-package kubel
  :commands (kubel)
  :config
  (fset 'k8s 'kubel))

(provide 'common-dev-modes)
