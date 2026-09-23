;;; my-git.el --- Git integration (magit, diff-hl) -*- lexical-binding: t; -*-

(use-package magit
  :bind ("C-x g" . magit-status))

;; Git change indicators in the fringe (updates on save / magit refresh)
(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (magit-post-refresh . diff-hl-magit-post-refresh)))

;; Ediff's default opens its control panel as a separate frame, which on macOS
;; steals focus and lands behind the Emacs window.  A plain single-frame layout
;; with side-by-side buffers is far easier to drive.
(use-package ediff
  :ensure nil
  :custom
  (ediff-window-setup-function #'ediff-setup-windows-plain)
  (ediff-split-window-function #'split-window-horizontally)
  ;; Ediff scatters windows; restore the previous layout when it exits.
  :hook (ediff-quit . winner-undo))

(provide 'my-git)
;;; my-git.el ends here
