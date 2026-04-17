;;; -*- lexical-binding: t; -*-

;; Package Setup

(require 'package)
(setq package-archive-priorities '(("gnu" . 5)
				   ("melpa" . 10)
				   ("nongnu" . 15))
      package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
			 ("melpa" . "https://melpa.org/packages/")
			 ("nongnu" . "https://elpa.nongnu.org/nongnu/packages")))

(package-initialize)

;; use-package-ensure must be explicitly loaded in Emacs 29+
;; Without this, :ensure t silently does nothing
(require 'use-package-ensure)
(setq use-package-always-ensure t)

;; Auto-refresh stale package archives on install failure
(defun my/package-install-retry (fn &rest args)
  "Retry package install once after refreshing archives.
Re-signals the error from the retry if it still fails."
  (condition-case _
      (apply fn args)
    (error
     (package-refresh-contents)
     (condition-case err2
         (apply fn args)
       (error (signal (car err2) (cdr err2)))))))
(advice-add 'package-install :around #'my/package-install-retry)

;; Externalise Custom into its own file so init.el stays hand-written only.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file :noerror))

;;;;; End Package Setup

(prefer-coding-system 'utf-8)

(setq inhibit-startup-message t)
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tooltip-mode) (tooltip-mode -1))
(if (fboundp 'set-fringe-mode) (set-fringe-mode 10))

;; macOS: Right Option as normal modifier for special chars (] | ~ @ etc.)
(setq ns-right-alternate-modifier 'none)

;; Backup and auto-save files in central directory
(setq backup-directory-alist '(("." . "~/.emacs.d/backups/"))
      auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-saves/" t)))

;; Ensure backup directories exist so Emacs doesn't silently skip backups
(dolist (dir '("~/.emacs.d/backups/" "~/.emacs.d/auto-saves/"))
  (let ((expanded (expand-file-name dir)))
    (unless (file-directory-p expanded)
      (make-directory expanded t))))

;; Only needed in GUI Emacs; terminal sessions inherit the shell env already.
(use-package exec-path-from-shell
  :when (memq window-system '(mac ns x))
  :config
  (exec-path-from-shell-initialize))

;; Look 'n feel
;;

;; Font
;; Manually install Nerd-Fonts (e.g. Sauce Code Pro) https://www.nerdfonts.com/
(when (find-font (font-spec :name "SauceCodePro NF"))
  (set-frame-font "SauceCodePro NF 14" nil t))

;; Relative line-numbers (only in code/text buffers, not magit/dired/help/etc.)
(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'display-line-numbers-mode)

;; Highlight matching parens (built-in; smartparens handles structural editing)
(show-paren-mode 1)

;; Color-coded delimiters by nesting depth
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Show column numbers
(column-number-mode 1)

;; Resolve symlinks in visited file names (affects buffer-file-name, modeline, VC).
;; Trade-off: projects accessed via symlink show the underlying absolute path.
(setq find-file-visit-truename t)

;; Ivy
(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package ivy-posframe
  :after ivy
  :config
  (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-center)))
  (ivy-posframe-mode 1))

(use-package swiper
  :after ivy)
(use-package counsel
  :after ivy)

;; Nerd-Icons
;; Manually install Nerd-Fonts (e.g. Sauce Code Pro) https://www.nerdfonts.com/
;; After installing nerd-icons and using Sauce Code Pro in Terminal run
;; M-x nerd-icons-install-fonts
(use-package nerd-icons)
(use-package nerd-icons-dired
  :hook
  (dired-mode . nerd-icons-dired-mode))
(use-package nerd-icons-ivy-rich
  :init
  (nerd-icons-ivy-rich-mode 1)
  (ivy-rich-mode 1))
(use-package nerd-icons-ibuffer
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))
(use-package nerd-icons-completion
  :config
  (nerd-icons-completion-mode))

;; Doom themes -> Zenburn
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-zenburn t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

(use-package treemacs
  :bind (("C-c C-p" . treemacs-add-and-display-current-project-exclusively)
         :map treemacs-mode-map
         ([mouse-1] . treemacs-single-click-expand-action))
  :custom
  (treemacs-width 35)
  (treemacs-is-never-other-window t))

(use-package treemacs-nerd-icons
  :after treemacs
  :config
  (treemacs-load-theme "nerd-icons"))

(use-package treemacs-projectile
  :after (treemacs projectile))

;; Doom modeline
(use-package doom-modeline
  :init (doom-modeline-mode 1))

;; Show possible key combinations
(use-package which-key
  :ensure nil
  :config
  (which-key-mode))

;; End look 'n feel
;;

;; Flexible completion matching (space-separated components)
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; In-buffer completion popup
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

(use-package projectile
  :config
  (projectile-mode +1)
  :bind-keymap ("s-p" . projectile-command-map))

(use-package smartparens
  :hook (prog-mode . smartparens-mode))

(use-package multi-term
  :custom (multi-term-program (or (getenv "SHELL") "/bin/zsh")))

(use-package ws-butler
  :hook (prog-mode . ws-butler-mode))

(use-package multiple-cursors
  :bind (("C-c m" . mc/mark-all-dwim)
         ("C-M-c" . mc/edit-lines)
         ("C-M-a" . mc/mark-all-like-this)
         ("C-M-p" . mc/mark-previous-like-this)
         ("C-M-n" . mc/mark-next-like-this)
         ("C-M-<" . mc/skip-to-previous-like-this)
         ("C-M->" . mc/skip-to-next-like-this)))

(use-package expand-region
  :bind ("C-M-l" . er/expand-region))

;; Git
(use-package magit
  :bind ("C-x g" . magit-status))

;; Git change indicators in the fringe
(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (diff-hl-flydiff-mode 1))

;; Better help buffers with source, references and examples
(use-package helpful
  :bind (("C-h f" . helpful-callable)
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)
         ("C-h x" . helpful-command)))

;; AI Agent shell (Cursor CLI via ACP)
;; Pinned revisions keep installs reproducible; bump SHAs intentionally.
(use-package shell-maker)

(use-package acp
  :vc (:url "https://github.com/xenodium/acp.el"
       :rev "863f2d62c4b4da8b229581be42d490a7403b2eb1"))

(use-package agent-shell
  :vc (:url "https://github.com/xenodium/agent-shell"
       :rev "209c413f468594a9ad291805b424eb2f7b769767")
  :after (acp shell-maker)
  :commands agent-shell
  :bind ("C-c a" . agent-shell)
  :config
  (require 'agent-shell-cursor)
  (let ((agent-bin (expand-file-name "~/.local/bin/agent")))
    (when (file-executable-p agent-bin)
      (setq agent-shell-cursor-acp-command (list agent-bin "acp")))))

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(require 'common-dev-modes)
