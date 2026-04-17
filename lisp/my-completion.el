;;; my-completion.el --- Minibuffer and in-buffer completion (vertico/consult/marginalia/embark/corfu) -*- lexical-binding: t; -*-

;;; Minibuffer (Vertico + Consult + Marginalia + Embark)

;; Persist minibuffer history across sessions; vertico orders by frequency.
(use-package savehist
  :ensure nil
  :init (savehist-mode 1))

;; Vertical minibuffer completion UI on top of Emacs' native `completing-read'
(use-package vertico
  :init (vertico-mode))

;; Centered overlay, same UX as ivy-posframe
(use-package vertico-posframe
  :after vertico
  :config
  (vertico-posframe-mode 1))

;; Flexible completion matching (space-separated components)
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; Right-aligned annotations in minibuffer (docstrings, file sizes, keys, ...)
(use-package marginalia
  :init (marginalia-mode))

;; Enhanced commands (consult-line, consult-buffer, consult-ripgrep, ...)
(use-package consult
  :bind (("C-s"     . consult-line)
         ("C-x b"   . consult-buffer)
         ("M-y"     . consult-yank-pop)
         ("M-g g"   . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g o"   . consult-outline)
         ("M-g i"   . consult-imenu)
         ("M-g m"   . consult-mark)
         ("M-s l"   . consult-line)
         ("M-s r"   . consult-ripgrep)
         ("M-s g"   . consult-grep)))

;; Bridge consult with projectile (consult-projectile-switch-project etc.)
(use-package consult-projectile
  :after (consult projectile)
  :bind ("C-c p p" . consult-projectile-switch-project))

;; Right-click-style action menu for any minibuffer/buffer item
(use-package embark
  :bind (("C-."   . embark-act)
         ("C-h B" . embark-bindings)))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;;; In-buffer (Corfu + Cape)

(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.2)
  (corfu-auto-prefix 1)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  :init
  (global-corfu-mode))

(use-package nerd-icons-corfu
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; Extra completion sources (file paths, buffer words, etc.)
(use-package cape
  :init
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-dabbrev))

(provide 'my-completion)
;;; my-completion.el ends here
