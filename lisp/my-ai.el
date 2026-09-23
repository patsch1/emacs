;;; my-ai.el --- AI Agent shell (Cursor CLI via ACP) -*- lexical-binding: t; -*-

;; Track the latest revisions; these packages are updated with
;; `package-vc-upgrade-all'.

(use-package shell-maker :defer t)

(use-package acp
  :defer t
  :vc (:url "https://github.com/xenodium/acp.el"
       :rev :newest))

;; No `:after (acp shell-maker)' here: both are declared `:defer t' with no
;; trigger of their own, so they never load, `:after' never fires, and the
;; `:bind' below would never take effect -- C-c a stayed unbound while
;; `M-x agent-shell' still worked via package.el's own autoloads.  agent-shell
;; requires both at load time anyway, so the dependency is already expressed.
(use-package agent-shell
  :vc (:url "https://github.com/xenodium/agent-shell"
       :rev :newest)
  :commands agent-shell
  :bind ("C-c a" . agent-shell)
  :config
  (require 'agent-shell-cursor)
  (let ((agent-bin (expand-file-name "~/.local/bin/agent")))
    (when (file-executable-p agent-bin)
      (setq agent-shell-cursor-acp-command (list agent-bin "acp")))))

(provide 'my-ai)
;;; my-ai.el ends here
