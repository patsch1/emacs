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
;; `org-replace-disputed-keys' is set below, before org is ever loaded, so org
;; moves those bindings to C-c C-S-<arrows> and windmove keeps S-<arrows>.

;;; Code:

;; Undo and redo window-layout changes with C-c <left> / C-c <right>.
(use-package winner
  :ensure nil
  :init (winner-mode 1))

(use-package ace-window
  :bind (("M-o"   . ace-window)
         ("C-x o" . ace-window))
  :custom
  (aw-scope 'frame)
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (aw-background t)
  (aw-dispatch-always nil)
  (aw-minibuffer-flag t))

;; Must be set before org loads; org reads it at load time only.  Declared
;; here rather than in an org module because this config has none: the setting
;; exists purely to protect the windmove bindings below.
(defvar org-replace-disputed-keys)
(setq org-replace-disputed-keys t)

(use-package windmove
  :ensure nil
  :custom
  (windmove-wrap-around t)
  :config
  (windmove-default-keybindings 'shift))

(provide 'my-windows)
;;; my-windows.el ends here
