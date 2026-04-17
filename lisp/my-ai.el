;;; my-ai.el --- AI Agent shell (Cursor CLI via ACP) -*- lexical-binding: t; -*-

;; Pinned revisions keep installs reproducible; bump SHAs intentionally.

(use-package shell-maker :defer t)

(use-package acp
  :defer t
  :vc (:url "https://github.com/xenodium/acp.el"
       :rev "863f2d62c4b4da8b229581be42d490a7403b2eb1"))

(use-package agent-shell
  :vc (:url "https://github.com/xenodium/agent-shell"
       :rev "209c413f468594a9ad291805b424eb2f7b769767")
  :after (acp shell-maker)
  :commands agent-shell
  :bind ("C-c a" . agent-shell)
  :config
  (require 'agent-shell-cursor)
  (let ((agent-bin (expand-file-name "~/.local/bin/agent")))
    (when (file-executable-p agent-bin)
      (setq agent-shell-cursor-acp-command (list agent-bin "acp")))))

(provide 'my-ai)
;;; my-ai.el ends here
