;;; my-ai.el --- AI Agent shell (Cursor CLI via ACP) -*- lexical-binding: t; -*-

;; Track the latest revisions; these packages are updated with
;; `package-vc-upgrade-all'.

(use-package shell-maker :defer t)

(use-package acp
  :defer t
  :vc (:url "https://github.com/xenodium/acp.el"
       :rev :newest))

(use-package agent-shell
  :vc (:url "https://github.com/xenodium/agent-shell"
       :rev :newest)
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
