;;; init.el --- Patrick's Emacs configuration -*- lexical-binding: t; -*-

;;; Version guard

;; This config targets Emacs 31.1+ (uses treesit-enabled-modes, built-in which-key, electric-pair).
(when (version< emacs-version "31.1")
  (error "This configuration requires Emacs 31.1 or later (found %s)"
         emacs-version))

;;; Package setup

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(require 'my-packages)

;; Externalise Custom into its own file so init.el stays hand-written only.
;; Package settings remain configuration-managed even if Custom has previously
;; written stale values for them.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file :noerror)
  (my/package-apply-managed-settings))

;;; Base settings

(prefer-coding-system 'utf-8)

(setq inhibit-startup-message t)

;; Emacs defaults that predate modern expectations.  All of these are still
;; off/verbose in 31.1, so they have to be set explicitly.
(setq use-short-answers t                ; y/n instead of typing yes/no
      sentence-end-double-space nil      ; single space ends a sentence
      require-final-newline t            ; already the default; kept explicit
      history-delete-duplicates t)       ; keep minibuffer history compact
(setq-default indent-tabs-mode nil)      ; indent with spaces

;; Typing or yanking over an active region replaces it.
(delete-selection-mode 1)

;; Right-click opens a context menu instead of the old mouse-save-then-kill.
(context-menu-mode 1)
(if (fboundp 'menu-bar-mode)   (menu-bar-mode   -1))
(if (fboundp 'tool-bar-mode)   (tool-bar-mode   -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tooltip-mode)    (tooltip-mode    -1))
(if (fboundp 'set-fringe-mode) (set-fringe-mode 10))

;; Smooth trackpad scrolling.  Enabled unconditionally rather than behind
;; `display-graphic-p': under --daemon no frame exists yet at init time, so
;; that test would wrongly skip it for GUI frames created later.  The mode is
;; inert on TTY frames.
(pixel-scroll-precision-mode 1)

;; macOS: Right Option as normal modifier for special chars (] | ~ @ etc.)
(defvar ns-right-alternate-modifier)
(setq ns-right-alternate-modifier 'none)

;; Backup and auto-save files in central directory
(setq backup-directory-alist '(("." . "~/.emacs.d/backups/"))
      auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-saves/" t))
      version-control t
      kept-new-versions 10
      kept-old-versions 2
      delete-old-versions t)

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

;;; Modules

(require 'my-ui)
(require 'my-completion)
(require 'my-editing)
(require 'my-git)
(require 'my-windows)
(require 'my-ai)
(require 'common-dev-modes)

;;; init.el ends here
