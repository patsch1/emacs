;;; my-ui.el --- UI: fonts, line numbers, icons, theme, treemacs, modeline -*- lexical-binding: t; -*-

;;; Visual basics

;; Font
;; Manually install Nerd-Fonts (e.g. Sauce Code Pro) https://www.nerdfonts.com/
(when (find-font (font-spec :name "SauceCodePro NF"))
  (set-frame-font "SauceCodePro NF 14" nil t))

;; Relative line-numbers (only in code/text buffers, not magit/dired/help/etc.)
(defvar display-line-numbers-type)
(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'display-line-numbers-mode)

;; Highlight matching parens.  In tree-sitter modes Emacs 31 feeds parser
;; results to show-paren via `treesit-show-paren-data'.
(show-paren-mode 1)

;; Color-coded delimiters by nesting depth
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Show column numbers
(column-number-mode 1)

;; Resolve symlinks in visited file names (affects buffer-file-name, modeline, VC).
;; Trade-off: projects accessed via symlink show the underlying absolute path.
(setq find-file-visit-truename t)

;;; Nerd Icons
;; Manually install Nerd-Fonts (e.g. Sauce Code Pro) https://www.nerdfonts.com/
;; After installing nerd-icons and using Sauce Code Pro in Terminal run
;; M-x nerd-icons-install-fonts

(use-package nerd-icons)

(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-ibuffer
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

(use-package nerd-icons-completion
  :config
  (nerd-icons-completion-mode))

;;; Theme

(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-zenburn t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

;;; Treemacs

;; Bound to C-c T, not C-c C-p: `C-c C-<letter>' is reserved for major modes,
;; and they win -- C-c C-p reached `run-python' in python-ts-mode and
;; `markdown-outline-previous' in markdown-mode, never Treemacs.
(use-package treemacs
  :bind (("C-c T" . treemacs-add-and-display-current-project-exclusively)
         :map treemacs-mode-map
         ([mouse-1] . treemacs-single-click-expand-action))
  :custom
  (treemacs-width 35)
  (treemacs-is-never-other-window t))

(use-package treemacs-nerd-icons
  :after treemacs
  :config
  (declare-function treemacs-load-theme "treemacs")
  (treemacs-load-theme "nerd-icons"))

(use-package treemacs-projectile
  :after (treemacs projectile))

;;; Modeline

;; NB: `mode-line-collapse-minor-modes' (Emacs 31) is deliberately NOT set --
;; doom-modeline renders its own mode line and hides minor modes entirely
;; (`doom-modeline-minor-modes' defaults to nil), so the option would be a
;; no-op here.  Enable that variable first if you ever want it to matter.
(use-package doom-modeline
  :init (doom-modeline-mode 1))

;;; Helpers

;; Show possible key combinations
(use-package which-key
  :ensure nil
  :config
  (which-key-mode))

;; Better help buffers with source, references and examples
(use-package helpful
  :bind (("C-h f" . helpful-callable)
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)
         ("C-h x" . helpful-command)))

(provide 'my-ui)
;;; my-ui.el ends here
