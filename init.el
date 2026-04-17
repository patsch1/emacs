;;; init.el --- Patrick's Emacs configuration -*- lexical-binding: t; -*-

;;; Version guard

;; This config targets Emacs 30.1+ (uses use-package :vc and built-in which-key).
(when (version< emacs-version "30.1")
  (error "This configuration requires Emacs 30.1 or later (found %s)"
         emacs-version))

;;; Package setup

(require 'package)
(setq package-archive-priorities '(("gnu"    . 5)
                                   ("melpa"  . 10)
                                   ("nongnu" . 15))
      package-archives '(("gnu"    . "https://elpa.gnu.org/packages/")
                         ("melpa"  . "https://melpa.org/packages/")
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
;; NOTE: custom.el is loaded AFTER `package-initialize'. Do not manage
;; `package-selected-packages' or `package-archives' via M-x customize; use
;; plain `setq' above instead to ensure they apply before package init.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file :noerror))

;;; Base settings

(prefer-coding-system 'utf-8)

(setq inhibit-startup-message t)
(if (fboundp 'menu-bar-mode)   (menu-bar-mode   -1))
(if (fboundp 'tool-bar-mode)   (tool-bar-mode   -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tooltip-mode)    (tooltip-mode    -1))
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

;;; Modules

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'my-ui)
(require 'my-completion)
(require 'my-editing)
(require 'my-git)
(require 'my-ai)
(require 'common-dev-modes)

;;; init.el ends here
