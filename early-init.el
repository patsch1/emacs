;;; early-init.el --- Early startup optimizations -*- lexical-binding: t; -*-

;; Prevent package.el from loading packages before init.el runs
(setq package-enable-at-startup nil)

;; Faster startup: temporarily disable expensive file-name-handler and GC
(defvar file-name-handler-alist-original file-name-handler-alist
  "Backup of the original `file-name-handler-alist' to restore after startup.")
(setq file-name-handler-alist nil
      gc-cons-threshold most-positive-fixnum)

(defun my/restore-startup-settings ()
  "Restore `file-name-handler-alist' and runtime GC/process-output thresholds after startup."
  (setq file-name-handler-alist file-name-handler-alist-original
        gc-cons-threshold 100000000
        read-process-output-max (* 1024 1024)))

(add-hook 'emacs-startup-hook #'my/restore-startup-settings)
