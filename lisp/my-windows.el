;;; my-windows.el --- Window navigation (ace-window, windmove) -*- lexical-binding: t; -*-

;;; Commentary:
;; Fast window switching:
;;   - ace-window  : letter overlay on each window, single-keystroke jump
;;   - windmove    : directional movement via S-<left/right/up/down>
;;
;; ace-window is bound to both M-o (default upstream) and C-x o (drop-in
;; replacement for the built-in `other-window').  Scope is restricted to the
;; current frame; use C-x 5 o to switch frames.
;;
;; Note: S-<arrows> conflicts with org-mode's `org-shift{left,right,up,down}'.
;; If you start using org-mode heavily, set
;;   (setq org-replace-disputed-keys t)
;; *before* loading org, or rebind windmove to a different modifier here.

;;; Code:

(use-package ace-window
  :bind (("M-o"   . ace-window)
         ("C-x o" . ace-window))
  :custom
  (aw-scope 'frame)
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (aw-background t)
  (aw-dispatch-always nil)
  (aw-minibuffer-flag t))

(use-package windmove
  :ensure nil
  :custom
  (windmove-wrap-around t)
  :config
  (windmove-default-keybindings 'shift))

(provide 'my-windows)
;;; my-windows.el ends here
