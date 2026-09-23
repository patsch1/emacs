;;; early-init.el --- Early startup optimizations -*- lexical-binding: t; -*-

;; Prevent package.el from loading packages before init.el runs
(setq package-enable-at-startup nil)

;; Prefer changed source files over stale bytecode left by manual compilation.
(setq load-prefer-newer t)

;; Faster startup: temporarily disable expensive file-name-handler and GC
(defvar file-name-handler-alist-original file-name-handler-alist
  "Backup of the original `file-name-handler-alist' to restore after startup.")
(setq file-name-handler-alist nil
      gc-cons-threshold most-positive-fixnum)

(defun my/restore-startup-settings ()
  "Restore file handlers and runtime thresholds after startup."
  ;; 100 MB was fine as a startup value but is costly at runtime: every
  ;; collection then has that much more to scan, which shows up as visible
  ;; pauses.  16 MB keeps allocation cheap without long sweeps.
  (setq file-name-handler-alist file-name-handler-alist-original
        gc-cons-threshold (* 16 1024 1024)
        read-process-output-max (* 1024 1024)))

(add-hook 'emacs-startup-hook #'my/restore-startup-settings)
