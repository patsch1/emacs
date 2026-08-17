;;; init.el --- Patrick's Emacs configuration -*- lexical-binding: t; -*-

;;; Version guard

;; This config targets Emacs 30.1+ (uses use-package :vc and built-in which-key).
(when (version< emacs-version "30.1")
  (error "This configuration requires Emacs 30.1 or later (found %s)"
         emacs-version))

;;; Package setup

(require 'package)
(require 'cl-lib)
(require 'subr-x)

;; `package-vc' checks out complete repositories.  Some upstream projects
;; don't ship an .elpaignore, so package.el would recursively byte-compile
;; their developer-only tests and fail on dependencies that users don't need.
(defun my/package-compile-ignore-development-files (original pkg-desc)
  "Add developer-only paths to ORIGINAL's ignore patterns.
PKG-DESC is the package descriptor passed to `package--parse-elpaignore'."
  (let* ((pkg-dir (file-name-as-directory (package-desc-dir pkg-desc)))
         (tests-dir (expand-file-name "tests" pkg-dir)))
    (append (list (concat (regexp-quote tests-dir) "\\(?:/\\|\\'\\)")
                  (concat (regexp-quote pkg-dir) "\\.[^/]+\\.el\\'"))
            (funcall original pkg-desc))))

(advice-add 'package--parse-elpaignore :around
            #'my/package-compile-ignore-development-files)

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

;; Signature verification disabled: GNU/NonGNU ELPA keyring is not bootstrapped
;; on this machine. To re-enable verification, initialise the keyring via
;;   gpg --homedir ~/.emacs.d/elpa/gnupg --keyserver hkps://keys.openpgp.org \
;;       --recv-keys 645357D2883A0966
;; and then remove the setq below (or set it to `allow-unsigned').
(setq package-check-signature nil)

(setq package-archive-priorities '(("gnu"    . 5)
                                   ("melpa"  . 10)
                                   ("nongnu" . 15))
      package-archives '(("gnu"    . "https://elpa.gnu.org/packages/")
                         ("melpa"  . "https://melpa.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/packages")))

(package-initialize)

;; use-package-ensure must be explicitly loaded in Emacs 29+
;; Without this, :ensure t silently does nothing
(require 'use-package-ensure)
(setq use-package-always-ensure t)

;; Auto-refresh stale package archives on install failure
(defun my/package-install-retry (fn &rest args)
  "Retry package install once after refreshing archives.
Re-signals the error from the retry if it still fails."
  (condition-case _
      (apply fn args)
    (error
     (package-refresh-contents)
     (condition-case err2
         (apply fn args)
       (error (signal (car err2) (cdr err2)))))))
(advice-add 'package-install :around #'my/package-install-retry)

;; Emacs 30 treats every installed VC package as upgradeable, even when its
;; checkout is current, and starts all pulls concurrently.  Check Git remotes
;; first, then rebuild only repositories that actually moved.
(defun my/package-git-run (directory &rest args)
  "Run Git with ARGS in DIRECTORY and return (STATUS . OUTPUT)."
  (with-temp-buffer
    (let ((default-directory (file-name-as-directory directory))
          (process-environment
           (cons "GIT_TERMINAL_PROMPT=0" process-environment)))
      (let ((status (apply #'process-file "git" nil t nil args)))
        (cons status (string-trim (buffer-string)))))))

(defun my/package-vc-git-state (pkg-desc)
  "Return the relation between PKG-DESC's Git HEAD and its upstream."
  (let* ((directory (package-desc-dir pkg-desc))
         (result (my/package-git-run
                  directory "rev-list" "--left-right" "--count"
                  "HEAD...@{upstream}")))
    (if (not (equal 0 (car result)))
        (list :state 'error :desc pkg-desc :message (cdr result))
      (pcase (mapcar #'string-to-number
                     (split-string (cdr result) "[[:space:]]+" t))
        (`(0 0) (list :state 'current :desc pkg-desc))
        (`(0 ,behind) (list :state 'update :desc pkg-desc
                            :commits behind))
        (`(,ahead 0) (list :state 'ahead :desc pkg-desc
                           :commits ahead))
        (`(,ahead ,behind)
         (list :state 'error :desc pkg-desc
               :message (format "local and upstream diverged (%d/%d)"
                                ahead behind)))
        (_ (list :state 'error :desc pkg-desc
                 :message "could not parse Git revision state"))))))

(defun my/package-vc-git-check (pkg-desc)
  "Fetch PKG-DESC's Git remote and return its resulting update state."
  (condition-case err
      (let ((fetch (my/package-git-run (package-desc-dir pkg-desc)
                                       "fetch" "--quiet")))
        (if (equal 0 (car fetch))
            (my/package-vc-git-state pkg-desc)
          (list :state 'error :desc pkg-desc :message (cdr fetch))))
    (error
     (list :state 'error :desc pkg-desc
           :message (error-message-string err)))))

(defun my/package-vc-git-apply-update (pkg-desc)
  "Fast-forward and rebuild the Git package described by PKG-DESC."
  (let ((merge (my/package-git-run (package-desc-dir pkg-desc)
                                   "merge" "--ff-only" "@{upstream}")))
    (unless (equal 0 (car merge))
      (error "%s" (cdr merge)))
    (require 'package-vc)
    (package-vc--unpack-1 pkg-desc (package-desc-dir pkg-desc))))

(defun my/package-upgrade-all (&optional query)
  "Upgrade archive and VC packages, checking Git revisions synchronously.
If QUERY is non-nil, ask before applying the upgrades."
  (interactive (list (not noninteractive)))
  (package-refresh-contents)
  (require 'package-vc)
  (let (archive-upgrades vc-updates vc-errors
        (vc-current 0))
    ;; `package--upgradeable-packages' intentionally includes every VC package;
    ;; retain only actual archive version upgrades from that list.
    (dolist (name (package--upgradeable-packages))
      (let ((desc (cadr (assq name package-alist))))
        (unless (and desc (package-vc-p desc))
          (push name archive-upgrades))))
    ;; Fetch and compare VC repositories before claiming they need upgrades.
    (dolist (entry package-alist)
      (when-let* ((desc (cadr entry))
                  ((package-vc-p desc)))
        (message "Checking VC package %s..." (package-desc-name desc))
        (redisplay)
        (let ((result (my/package-vc-git-check desc)))
          (pcase (plist-get result :state)
            ('update (push desc vc-updates))
            ((or 'current 'ahead) (cl-incf vc-current))
            ('error
             (push result vc-errors)
             (message "VC check failed for %s: %s"
                      (package-desc-name desc)
                      (plist-get result :message)))))))
    (setq archive-upgrades (nreverse archive-upgrades)
          vc-updates (nreverse vc-updates))
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
        (user-error "Upgrade aborted"))
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
          (message "Package upgrade complete: %d updated, %d VC current, %d failed"
                   updated vc-current failed)))))))

(advice-add 'package-upgrade-all :override #'my/package-upgrade-all)

;; Externalise Custom into its own file so init.el stays hand-written only.
;; NOTE: custom.el is loaded AFTER `package-initialize'. Do not manage
;; `package-selected-packages' or `package-archives' via M-x customize; use
;; plain `setq' above instead to ensure they apply before package init.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file :noerror))

;;; Base settings

(prefer-coding-system 'utf-8)

(setq inhibit-startup-message t)
(if (fboundp 'menu-bar-mode)   (menu-bar-mode   -1))
(if (fboundp 'tool-bar-mode)   (tool-bar-mode   -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tooltip-mode)    (tooltip-mode    -1))
(if (fboundp 'set-fringe-mode) (set-fringe-mode 10))

;; macOS: Right Option as normal modifier for special chars (] | ~ @ etc.)
(setq ns-right-alternate-modifier 'none)

;; Backup and auto-save files in central directory
(setq backup-directory-alist '(("." . "~/.emacs.d/backups/"))
      auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-saves/" t)))

;; Ensure backup directories exist so Emacs doesn't silently skip backups
(dolist (dir '("~/.emacs.d/backups/" "~/.emacs.d/auto-saves/"))
  (let ((expanded (expand-file-name dir)))
    (unless (file-directory-p expanded)
      (make-directory expanded t))))

;; Only needed in GUI Emacs; terminal sessions inherit the shell env already.
(use-package exec-path-from-shell
  :when (memq window-system '(mac ns x))
  :config
  (exec-path-from-shell-initialize))

;;; Modules

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'my-ui)
(require 'my-completion)
(require 'my-editing)
(require 'my-git)
(require 'my-windows)
(require 'my-ai)
(require 'common-dev-modes)

;;; init.el ends here
