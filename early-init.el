;; Prevent package.el from loading packages before init.el runs
(setq package-enable-at-startup nil)

;; Faster startup: temporarily disable expensive file-name-handler
(defvar file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
          (lambda () (setq file-name-handler-alist file-name-handler-alist-original)))

;; Higher GC threshold during startup, reset after
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold 100000000
                  read-process-output-max (* 1024 1024))))
