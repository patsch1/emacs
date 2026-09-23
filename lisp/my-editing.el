;;; my-editing.el --- Editing tools (projectile, electric-pair, terminal, cursors) -*- lexical-binding: t; -*-

;;; Project navigation

;; Restore point positions, notice external changes, and make command sequences
;; easier to repeat.  All three features are built into Emacs.
(use-package saveplace
  :ensure nil
  :init (save-place-mode 1))

(use-package autorevert
  :ensure nil
  :custom (global-auto-revert-non-file-buffers t)
  :init (global-auto-revert-mode 1))

(use-package repeat
  :ensure nil
  :init (repeat-mode 1))

(use-package projectile
  :config
  (projectile-mode +1)
  :bind-keymap ("s-p" . projectile-command-map))

;;; Files & directories

;; Dired ships with none of these on; all three are near-universal preferences.
;; NOTE: macOS has BSD `ls', which supports neither `--dired' nor
;; `--group-directories-first'.  `dired-use-ls-dired' is pinned to nil so Emacs
;; skips its probe, and the switches stay BSD-compatible.  With GNU coreutils
;; installed (brew install coreutils) you could set `insert-directory-program'
;; to "gls" and add --group-directories-first here.
(use-package dired
  :ensure nil
  :custom
  (dired-use-ls-dired nil)
  (dired-listing-switches "-alh")
  ;; With two dired windows open, default the copy/rename target to the other
  ;; window's directory.
  (dired-dwim-target t)
  ;; Reuse the buffer when descending instead of leaving a trail behind.
  (dired-kill-when-opening-new-dired-buffer t)
  ;; Recursive copy/delete without asking for every subdirectory.
  (dired-recursive-copies 'always)
  (dired-recursive-deletes 'top))

;;; Parens & whitespace

;; Electric Pair replaces smartparens here: this config only ever used
;; smartparens for plain auto-pairing, and Emacs 31 pairs multiple and
;; multi-character delimiters natively.  Structural navigation now comes
;; from tree-sitter, which drives `show-paren-mode', `forward-list',
;; `up-list' and `down-list' in ts-modes.
(use-package elec-pair
  :ensure nil
  :hook (prog-mode . electric-pair-local-mode))

(use-package ws-butler
  :hook (prog-mode . ws-butler-mode))

;; Async auto-format on save (replaces per-mode eglot-format hooks).
;; Requires external formatters (black, mix format, prettier, rustfmt, ...).
(use-package apheleia
  :config
  (apheleia-global-mode +1))

;;; Spell checking

;; jinx only checks the visible part of the buffer, which is what makes it
;; cheap enough to leave on everywhere.  In prog-mode it restricts itself to
;; comments and strings.
;;
;; It talks to Enchant, and Enchant on macOS carries an AppleSpell provider --
;; the very spell checker the rest of the system uses.  That means the words
;; learned here land in ~/Library/Spelling/LocalDictionary and are shared with
;; every other macOS app, in both directions.
;;
;; Requires `brew install enchant' plus an ordering file; see the Spell
;; Checking section of the README.  Note the generic language tags: AppleSpell
;; registers "en" and "de", while the aspell dictionaries Homebrew pulls in as
;; a dependency also register "en_US".  Enchant prefers an exact tag match, so
;; asking for "en_US" would silently route around macOS back to aspell.
;;
;; The tags select the provider, not the dictionary: with
;; `NSPreferredSpellServerLanguage' unset -- the macOS default, "Automatic by
;; Language" -- AppleSpell identifies the language itself, so mixed German and
;; English prose is handled correctly no matter which tag asked for it.
(use-package jinx
  :hook ((text-mode . jinx-mode)
         (prog-mode . jinx-mode))
  ;; `jinx-correct' walks every misspelling in the visible window inside a
  ;; `save-excursion', so point need not be on the word.  Its siblings are
  ;; reachable only from `jinx-overlay-map' (M-n/M-p while standing on a
  ;; marked word), which is useless when you have already moved past it --
  ;; hence the explicit prefix.  Deliberately not M-n/M-p in `jinx-mode-map':
  ;; flymake already owns those in prog-mode, and between two minor-mode maps
  ;; the winner depends on load order.  `repeat-mode' is on, so jinx's own
  ;; repeat map allows bare n/p/$ to continue after the first jump.
  :bind (("M-$"     . jinx-correct)    ; replaces `ispell-word'
         ("C-M-$"   . jinx-languages)
         ("C-c s n" . jinx-next)
         ("C-c s p" . jinx-previous)
         ("C-c s a" . jinx-correct-all))
  :custom
  (jinx-languages "en de"))

;;; Terminal

;; eat ships its own terminfo (eat-truecolor et al.).  The README documents
;; the one-time `tic' step to install it into ~/.terminfo so shells inside
;; eat render with 24-bit true color.
(use-package eat
  :commands (eat eat-project)
  :bind ("C-c t" . eat))

;;; Selection & cursors

(use-package multiple-cursors
  :bind (("C-c m"   . mc/mark-all-dwim)
         ("C-M-c"   . mc/edit-lines)
         ("C-M-a"   . mc/mark-all-like-this)
         ("C-M-p"   . mc/mark-previous-like-this)
         ("C-M-n"   . mc/mark-next-like-this)
         ("C-M-<"   . mc/skip-to-previous-like-this)
         ("C-M->"   . mc/skip-to-next-like-this)))

(use-package expand-region
  :bind ("C-M-l" . er/expand-region))

(provide 'my-editing)
;;; my-editing.el ends here
