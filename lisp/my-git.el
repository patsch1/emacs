;;; my-git.el --- Git integration (magit, diff-hl) -*- lexical-binding: t; -*-

(use-package magit
  :bind ("C-x g" . magit-status))

;; Git change indicators in the fringe (updates on save / magit refresh)
(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (magit-post-refresh . diff-hl-magit-post-refresh)))

(provide 'my-git)
;;; my-git.el ends here
