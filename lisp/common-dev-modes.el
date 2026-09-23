;;; common-dev-modes.el --- Language modes (Elixir, Python, YAML, Nix, etc.) -*- lexical-binding: t; -*-

;; Treesitter
;; Both GUI app and Homebrew CLI must be the same Emacs version to avoid
;; tree-sitter ABI mismatches when compiling grammars.
(use-package treesit
  :ensure nil
  :custom
  ;; Emacs ships no grammar URLs of its own; this list is what
  ;; `treesit-auto-install-grammar' consults when a mode needs a grammar.
  ;; Entries accept keywords, e.g. (json URL :commit "4d770d3") to pin.
  (treesit-language-source-alist
   '((heex "https://github.com/phoenixframework/tree-sitter-heex")
     (elixir "https://github.com/elixir-lang/tree-sitter-elixir")
     (python "https://github.com/tree-sitter/tree-sitter-python")
     (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile")
     (toml "https://github.com/tree-sitter/tree-sitter-toml")
     (yaml "https://github.com/ikatyang/tree-sitter-yaml")
     (json "https://github.com/tree-sitter/tree-sitter-json")
     (nix "https://github.com/nix-community/tree-sitter-nix")
     (hcl "https://github.com/MichaHoffmann/tree-sitter-hcl")))
  ;; Install a missing grammar on demand instead of compiling every grammar
  ;; eagerly at startup.  'ask is the Emacs default; stated here explicitly
  ;; because this config relies on the behaviour.
  (treesit-auto-install-grammar 'ask)
  ;; Kept in sync with the grammars above.  `treesit-enabled-modes' feeds
  ;; Emacs' own `treesit-major-mode-remap-alist' into `major-mode-remap-alist',
  ;; which replaces the hand-maintained remap list this config used to carry.
  ;; Use t instead to enable every bundled tree-sitter mode.
  (treesit-enabled-modes
   '(elixir-ts-mode
     heex-ts-mode
     python-ts-mode
     yaml-ts-mode
     json-ts-mode
     toml-ts-mode
     dockerfile-ts-mode)))

;; LSP via eglot (built-in)
;; Install LSPs:
;;   Elixir: https://github.com/elixir-lang/expert/releases -> ~/.local/bin/expert
;;   Python: pip install pyright
(use-package eglot
  :ensure nil
  ;; Eglot binds nothing by default beyond xref's M-. / M-?, so the LSP actions
  ;; that matter day to day need explicit keys.  Kept on the eglot-mode-map so
  ;; they only exist where a server is actually attached.
  :bind (:map eglot-mode-map
         ("C-c l r" . eglot-rename)
         ("C-c l a" . eglot-code-actions)
         ("C-c l f" . eglot-format)
         ("C-c l d" . eldoc-doc-buffer)
         ("C-c l i" . eglot-find-implementation)
         ("C-c l t" . eglot-find-typeDefinition)
         ("C-c l R" . eglot-reconnect)
         ("C-c l q" . eglot-shutdown))
  :config
  (let ((expert-bin (expand-file-name "~/.local/bin/expert")))
    (when (file-executable-p expert-bin)
      (add-to-list 'eglot-server-programs
                   `(elixir-ts-mode ,expert-bin "--stdio"))))
  (let ((terraform-ls-bin (executable-find "terraform-ls")))
    (when terraform-ls-bin
      (add-to-list 'eglot-server-programs
                   `(terraform-mode ,terraform-ls-bin "serve")))))

;; Flymake carries the diagnostics eglot produces, but `flymake-mode-map' is
;; empty out of the box -- it defines only a menu-bar entry and a fringe click.
;; Without these there is no way to step through errors from the keyboard.
;; `consult-flymake' gives a searchable overview of the whole buffer.
(use-package flymake
  :ensure nil
  :bind (:map flymake-mode-map
         ("M-n"     . flymake-goto-next-error)
         ("M-p"     . flymake-goto-prev-error)
         ("C-c e l" . flymake-show-buffer-diagnostics)
         ("C-c e p" . flymake-show-project-diagnostics)
         ("C-c e c" . consult-flymake))
  :custom
  ;; Do not start a syntax check on every keystroke.
  (flymake-no-changes-timeout 0.5))

;; Elixir (formatting handled by apheleia)
;; Built into Emacs since 30.1, together with `heex-ts-mode'.
(use-package elixir-ts-mode
  :ensure nil
  :hook (elixir-ts-mode . eglot-ensure))

;; Python (formatting handled by apheleia)
(use-package python
  :ensure nil
  :hook (python-ts-mode . eglot-ensure))

;;; Structural editing (tree-sitter AST)

;; Combobulate provides structural navigation/editing for tree-sitter modes.
;; Only activates in TS-modes; electric-pair covers pairing everywhere else.
;; Not on MELPA — track the latest revision via package-vc.
(use-package combobulate
  :vc (:url "https://github.com/mickeynp/combobulate"
       :rev :newest)
  :hook ((elixir-ts-mode    . combobulate-mode)
         (python-ts-mode    . combobulate-mode)
         (yaml-ts-mode      . combobulate-mode)
         (json-ts-mode      . combobulate-mode)
         (nix-ts-mode       . combobulate-mode)
         (toml-ts-mode      . combobulate-mode)
         (dockerfile-ts-mode . combobulate-mode)))

;; Dockerfile, HEEx, YAML, JSON, TOML and Elixir need no `:mode' entries:
;; Emacs' own `auto-mode-alist' already routes them to the `*-ts-mode-maybe'
;; dispatchers, which honour `treesit-enabled-modes' set above.

;;; Terraform
;; Classic terraform-mode (MELPA).  Emacs 31 still has no hcl-ts-mode; the HCL
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

;; Taskfile has no extension, so it needs an explicit entry; every other
;; YAML path is covered by the built-in `yaml-ts-mode-maybe' dispatcher.
(add-to-list 'auto-mode-alist '("\\`[Tt]askfile\\'" . yaml-ts-mode))

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
    (ansible-mode 1)))

(use-package ansible
  :commands (ansible-mode)
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
