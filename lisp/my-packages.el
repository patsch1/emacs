;;; my-packages.el --- Package installation and upgrades -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'package)
(require 'package-vc)
(require 'seq)
(require 'subr-x)

;; Keep direct dependencies explicit.  `package-autoremove' may remove anything
;; that is neither listed here nor required by one of these packages.
(defconst my/package-selected-packages
  '(ace-window
    acp
    agent-shell
    ansible
    apheleia
    cape
    combobulate
    consult
    consult-projectile
    corfu
    diff-hl
    doom-modeline
    doom-themes
    eat
    elixir-ts-mode
    embark
    embark-consult
    exec-path-from-shell
    expand-region
    helpful
    jinja2-mode
    kubel
    magit
    marginalia
    markdown-mode
    multiple-cursors
    nerd-icons
    nerd-icons-completion
    nerd-icons-corfu
    nerd-icons-dired
    nerd-icons-ibuffer
    nix-ts-mode
    orderless
    projectile
    rainbow-delimiters
    shell-maker
    smartparens
    terraform-mode
    treemacs
    treemacs-nerd-icons
    treemacs-projectile
    vertico
    vertico-posframe
    ws-butler
    yaml-mode)
  "Packages configured directly by this Emacs setup.")

(defconst my/package-archives
  '(("gnu"    . "https://elpa.gnu.org/packages/")
    ("nongnu" . "https://elpa.nongnu.org/nongnu/packages")
    ("melpa"  . "https://melpa.org/packages/"))
  "Package archives used by this configuration.")

(defconst my/package-archive-priorities
  '(("gnu" . 30) ("nongnu" . 20) ("melpa" . 10))
  "Prefer GNU and NonGNU packages when an archive contains duplicates.")

(defun my/package-apply-managed-settings ()
  "Restore package settings managed by this configuration.
This deliberately overrides stale values written to `custom-file'."
  (setq package-check-signature 'allow-unsigned
        package-archives (copy-tree my/package-archives)
        package-archive-priorities
        (copy-tree my/package-archive-priorities)
        package-selected-packages
        (copy-sequence my/package-selected-packages))
  ;; Custom stores variable values in its `user' theme.  Merely using `setq'
  ;; is insufficient because loading a color theme reapplies those old values.
  (custom-theme-set-variables
   'user
   `(package-check-signature 'allow-unsigned)
   `(package-archives ',my/package-archives)
   `(package-archive-priorities ',my/package-archive-priorities)
   `(package-selected-packages ',my/package-selected-packages)))

(my/package-apply-managed-settings)
(package-initialize)

;; use-package-ensure must be explicitly loaded in Emacs 29+.
(require 'use-package-ensure)
(setq use-package-always-ensure t)

;; `package-vc' checks out complete repositories.  Some upstream projects do
;; not ship an .elpaignore, so package.el would recursively byte-compile their
;; developer-only tests and fail on dependencies users do not need.
(defun my/package-compile-ignore-development-files (original pkg-desc)
  "Add developer-only paths to ORIGINAL's ignore patterns for PKG-DESC."
  (let* ((pkg-dir (file-name-as-directory (package-desc-dir pkg-desc)))
         (tests-dir (expand-file-name "tests" pkg-dir)))
    (append (list (concat (regexp-quote tests-dir) "\\(?:/\\|\\'\\)")
                  (concat (regexp-quote pkg-dir) "\\.[^/]+\\.el\\'"))
            (funcall original pkg-desc))))

(when (fboundp 'package--parse-elpaignore)
  (advice-add 'package--parse-elpaignore :around
              #'my/package-compile-ignore-development-files))

;; These packages work from bytecode, but their optional JIT native compilation
;; reports upstream cross-file references as prominent warnings on every
;; upgrade.  Keep native compilation enabled for all other packages.
(defvar native-comp-jit-compilation-deny-list)
(with-eval-after-load 'comp-run
  (dolist (package '("agent-shell" "combobulate"))
    (add-to-list
     'native-comp-jit-compilation-deny-list
     (concat (regexp-quote
              (file-name-as-directory
               (expand-file-name package package-user-dir)))
             ".*\\.elc?\\'"))))

;; Refresh only when installing a genuinely unknown archive package.  Broadly
;; retrying every package-install error can conceal compilation/config errors.
(defun my/package-refresh-before-missing-install (original package &rest args)
  "Refresh archives before ORIGINAL installs an unknown PACKAGE with ARGS."
  (when (and (symbolp package)
             (not (package-installed-p package))
             (not (assq package package-archive-contents)))
    (package-refresh-contents))
  (apply original package args))

(advice-add 'package-install :around
            #'my/package-refresh-before-missing-install)

;;; VC package upgrades

(defcustom my/package-vc-fetch-timeout 30
  "Seconds to wait for a VC package's Git fetch before cancelling it."
  :type 'integer
  :group 'package)

(defvar my/package-upgrade-in-progress nil
  "Non-nil while `package-upgrade-all' is checking or updating packages.")

(defun my/package-git-run (directory &rest args)
  "Run Git with ARGS in DIRECTORY and return (STATUS . OUTPUT)."
  (with-temp-buffer
    (let ((default-directory (file-name-as-directory directory))
          (process-environment
           (cons "GIT_TERMINAL_PROMPT=0" process-environment)))
      (let ((status (apply #'process-file "git" nil t nil args)))
        (cons status (string-trim (buffer-string)))))))

(defun my/package-vc-git-state (pkg-desc)
  "Return PKG-DESC's relation to its Git upstream after a fetch."
  (let ((result (my/package-git-run
                 (package-desc-dir pkg-desc)
                 "rev-list" "--left-right" "--count"
                 "HEAD...@{upstream}")))
    (if (not (equal 0 (car result)))
        (list :state 'error :desc pkg-desc :message (cdr result))
      (pcase (mapcar #'string-to-number
                     (split-string (cdr result) "[[:space:]]+" t))
        (`(0 0) (list :state 'current :desc pkg-desc))
        (`(0 ,behind) (list :state 'update :desc pkg-desc :commits behind))
        (`(,ahead 0) (list :state 'ahead :desc pkg-desc :commits ahead))
        (`(,ahead ,behind)
         (list :state 'error :desc pkg-desc
               :message (format "local and upstream diverged (%d/%d)"
                                ahead behind)))
        (_ (list :state 'error :desc pkg-desc
                 :message "could not parse Git revision state"))))))

(defun my/package-vc-git-fetch-async (pkg-desc callback)
  "Fetch PKG-DESC asynchronously and call CALLBACK with its update state."
  (let* ((name (package-desc-name pkg-desc))
         (buffer (generate-new-buffer (format " *package-fetch-%s*" name)))
         (default-directory
          (file-name-as-directory (package-desc-dir pkg-desc)))
         (process-environment
          (cons "GIT_TERMINAL_PROMPT=0" process-environment))
         process timer)
    (condition-case err
        (progn
          (setq process
                (make-process
                 :name (format "package-fetch-%s" name)
                 :buffer buffer
                 :command '("git" "fetch" "--quiet")
                 :noquery t
                 :sentinel
                 (lambda (proc _event)
                   (when (memq (process-status proc) '(exit signal))
                     (when timer (cancel-timer timer))
                     (let ((result
                            (cond
                             ((process-get proc 'my/timed-out)
                              (list :state 'error :desc pkg-desc
                                    :message
                                    (format "git fetch timed out after %ds"
                                            my/package-vc-fetch-timeout)))
                             ((zerop (process-exit-status proc))
                              (my/package-vc-git-state pkg-desc))
                             (t
                              (list :state 'error :desc pkg-desc
                                    :message
                                    (string-trim
                                     (with-current-buffer buffer
                                       (buffer-string))))))))
                       (unwind-protect
                           (funcall callback result)
                         (when (buffer-live-p buffer)
                           (kill-buffer buffer))))))))
          (when (process-live-p process)
            (setq timer
                  (run-at-time
                   my/package-vc-fetch-timeout nil
                   (lambda ()
                     (when (process-live-p process)
                       (process-put process 'my/timed-out t)
                       (delete-process process)))))))
      (error
       (when (buffer-live-p buffer) (kill-buffer buffer))
       (funcall callback
                (list :state 'error :desc pkg-desc
                      :message (error-message-string err)))))))

(defun my/package-vc-check-all-async (descs callback)
  "Check Git package DESCS sequentially, then call CALLBACK.
CALLBACK receives (UPDATES CURRENT ERRORS)."
  (let (updates errors
        (current 0))
    (cl-labels
        ((next
          (remaining)
          (if-let ((desc (car remaining)))
              (progn
                (message "Checking VC package %s..."
                         (package-desc-name desc))
                (my/package-vc-git-fetch-async
                 desc
                 (lambda (result)
                   (pcase (plist-get result :state)
                     ('update (push desc updates))
                     ((or 'current 'ahead) (cl-incf current))
                     ('error
                      (push result errors)
                      (message "VC check failed for %s: %s"
                               (package-desc-name desc)
                               (plist-get result :message))))
                   (next (cdr remaining)))))
            (funcall callback (nreverse updates) current
                     (nreverse errors)))))
      (next descs))))

(defun my/package-archive-upgrades ()
  "Return installed archive packages with a newer available version."
  (cl-loop for (name installed) in package-alist
           for available = (cadr (assq name package-archive-contents))
           when (and installed
                     available
                     (not (package-vc-p installed))
                     (version-list-< (package-desc-version installed)
                                     (package-desc-version available)))
           collect name))

(defun my/package-vc-git-apply-update (pkg-desc)
  "Fast-forward and rebuild the Git package described by PKG-DESC."
  (let ((merge (my/package-git-run (package-desc-dir pkg-desc)
                                   "merge" "--ff-only" "@{upstream}")))
    (unless (equal 0 (car merge))
      (error "%s" (cdr merge)))
    (unless (fboundp 'package-vc--unpack-1)
      (error "This Emacs version has no compatible package-vc unpack API"))
    ;; Emacs 30 has no public API for rebuilding an already-updated checkout.
    (package-vc--unpack-1 pkg-desc (package-desc-dir pkg-desc))))

(defun my/package-finish-upgrade (archive-upgrades vc-updates vc-current
                                                    vc-errors query)
  "Apply checked package upgrades and report a summary.
ARCHIVE-UPGRADES and VC-UPDATES name the work to do.  VC-CURRENT and
VC-ERRORS contain the check results.  When QUERY is non-nil, ask first."
  (let ((total (+ (length archive-upgrades) (length vc-updates))))
    (cond
     ((zerop total)
      (message "All packages are current%s"
               (if vc-errors
                   (format " (%d VC check(s) failed; see *Messages*)"
                           (length vc-errors))
                 "")))
     ((and query
           (not (yes-or-no-p
                 (format "Upgrade %d package(s) (%d archive, %d VC)? "
                         total (length archive-upgrades)
                         (length vc-updates)))))
      (message "Package upgrade aborted"))
     (t
      (let ((updated 0)
            (failed (length vc-errors)))
        (dolist (name archive-upgrades)
          (condition-case err
              (progn (package-upgrade name) (cl-incf updated))
            (error
             (cl-incf failed)
             (message "Upgrade failed for %s: %s"
                      name (error-message-string err)))))
        ;; Rebuild one checkout at a time; package-vc's concurrent activation
        ;; can otherwise race while mutating `package-alist'.
        (dolist (desc vc-updates)
          (condition-case err
              (progn
                (message "Upgrading VC package %s..."
                         (package-desc-name desc))
                (my/package-vc-git-apply-update desc)
                (cl-incf updated))
            (error
             (cl-incf failed)
             (message "Upgrade failed for %s: %s"
                      (package-desc-name desc)
                      (error-message-string err)))))
        (message
         "Package upgrade complete: %d updated, %d VC current, %d failed"
         updated vc-current failed))))))

(defun my/package-upgrade-all (&optional query)
  "Upgrade archive and VC packages without concurrent VC pulls.
Git fetches run asynchronously and sequentially, with a timeout.  If QUERY is
non-nil, ask before applying the upgrades."
  (interactive (list (not noninteractive)))
  (when my/package-upgrade-in-progress
    (user-error "A package upgrade is already in progress"))
  (setq my/package-upgrade-in-progress t)
  (condition-case err
      (progn
        (package-refresh-contents)
        (let ((archive-upgrades (my/package-archive-upgrades))
              (vc-descs
               (cl-loop for (_name desc) in package-alist
                        when (and desc (package-vc-p desc))
                        collect desc)))
          (my/package-vc-check-all-async
           vc-descs
           (lambda (vc-updates vc-current vc-errors)
             (unwind-protect
                 (my/package-finish-upgrade
                  archive-upgrades vc-updates vc-current vc-errors query)
               (setq my/package-upgrade-in-progress nil))))))
    (error
     (setq my/package-upgrade-in-progress nil)
     (signal (car err) (cdr err)))))

(advice-add 'package-upgrade-all :override #'my/package-upgrade-all)

(provide 'my-packages)
;;; my-packages.el ends here
