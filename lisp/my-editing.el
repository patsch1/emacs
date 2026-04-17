;;; my-editing.el --- Editing tools (projectile, smartparens, terminal, cursors) -*- lexical-binding: t; -*-

;;; Project navigation

(use-package projectile
  :config
  (projectile-mode +1)
  :bind-keymap ("s-p" . projectile-command-map))

;;; Parens & whitespace

(use-package smartparens
  :hook (prog-mode . smartparens-mode))

(use-package ws-butler
  :hook (prog-mode . ws-butler-mode))

;;; Terminal

(use-package multi-term
  :custom (multi-term-program (or (getenv "SHELL") "/bin/zsh")))

;;; Selection & cursors

(use-package multiple-cursors
  :bind (("C-c m"   . mc/mark-all-dwim)
         ("C-M-c"   . mc/edit-lines)
         ("C-M-a"   . mc/mark-all-like-this)
         ("C-M-p"   . mc/mark-previous-like-this)
         ("C-M-n"   . mc/mark-next-like-this)
         ("C-M-<"   . mc/skip-to-previous-like-this)
         ("C-M->"   . mc/skip-to-next-like-this)))

(use-package expand-region
  :bind ("C-M-l" . er/expand-region))

(provide 'my-editing)
;;; my-editing.el ends here
