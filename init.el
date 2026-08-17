;;; init.el --- Patrick's Emacs configuration -*- lexical-binding: t; -*-

;;; Version guard

;; This config targets Emacs 30.1+ (uses use-package :vc and built-in which-key).
(when (version< emacs-version "30.1")
  (error "This configuration requires Emacs 30.1 or later (found %s)"
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
(if (fboundp 'menu-bar-mode)   (menu-bar-mode   -1))
(if (fboundp 'tool-bar-mode)   (tool-bar-mode   -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tooltip-mode)    (tooltip-mode    -1))
(if (fboundp 'set-fringe-mode) (set-fringe-mode 10))

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
