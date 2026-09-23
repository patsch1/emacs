# Changelog

## 2026-09-23

Migration auf Emacs 31.1. Version-Guard von `30.1` auf `31.1` angehoben.

### Fix

- `task lint` schlug unter Emacs 31 hart fehl: `if-let` ist seit 31.1 obsolet und `byte-compile-error-on-warn` macht daraus einen Fehler — ersetzt durch `if-let*` (`lisp/my-packages.el`)
- VC-Paket-Upgrades waren unter Emacs 31 zur Laufzeit kaputt: `package-vc--unpack-1` nimmt dort nur noch ein Argument, wurde aber mit zweien aufgerufen. Ersetzt durch die in Emacs 31 öffentliche `package-vc-rebuild`; der `fboundp`-Guard entfällt damit
- `gc-cons-threshold` blieb nach dem Start dauerhaft auf 100 MB und verursachte lange GC-Pausen — Laufzeitwert auf 16 MB gesenkt (`early-init.el`)

### Refactor

- Tree-sitter: manueller Grammar-Install-Loop und handgepflegte `major-mode-remap-alist` ersetzt durch `treesit-enabled-modes` und `treesit-auto-install-grammar`. Emacs 31 liefert `treesit-major-mode-remap-alist` vorbefüllt aus. Grammars werden nicht mehr bei jedem Start geprüft, sondern bei Bedarf mit Rückfrage installiert
  - Achtung: `treesit-enabled-modes` hat einen `:set`-Setter — ein einfaches `setq` füllt `major-mode-remap-alist` **nicht**. Deshalb via `:custom`
- `use-package emacs` → `use-package treesit` (passender Feature-Name für den Block)
- `smartparens` durch das eingebaute `electric-pair-local-mode` ersetzt: die Konfiguration nutzte smartparens nur für simples Auto-Pairing. Strukturelle Navigation kommt in Emacs 31 von tree-sitter, das `show-paren-mode`, `forward-list`, `up-list` und `down-list` in TS-Modes bedient

### Feat

- eglot-Keybindings auf `eglot-mode-map` (`C-c l` Prefix): rename, code-actions, format, doc-buffer, find-implementation, find-typeDefinition, reconnect, shutdown
- flymake-Keybindings auf `flymake-mode-map`: `M-n` / `M-p` für nächsten/vorigen Fehler, `C-c e l` / `C-c e p` für Buffer-/Projekt-Diagnosen, `C-c e c` für `consult-flymake`. `flymake-mode-map` war ab Werk leer (nur Menü-Eintrag und Fringe-Klick) — es gab keinen Tastaturweg zu den LSP-Diagnosen
- Dired-Konfiguration: `dired-dwim-target`, `dired-kill-when-opening-new-dired-buffer`, rekursives Kopieren/Löschen. `dired-use-ls-dired` auf `nil` und Switches auf `-alh`, da macOS BSD-`ls` weder `--dired` noch `--group-directories-first` kennt
- Ediff-Konfiguration: `ediff-setup-windows-plain` statt separatem Control-Frame, Buffer nebeneinander, `winner-undo` beim Beenden zur Wiederherstellung des Fensterlayouts
- Base-Defaults in `init.el`: `use-short-answers`, `delete-selection-mode`, `context-menu-mode`, `pixel-scroll-precision-mode`, `indent-tabs-mode nil`, `sentence-end-double-space nil`, `history-delete-duplicates`
- `savehist-additional-variables` um `kill-ring`, `search-ring` und `regexp-search-ring` erweitert
- `mode-line-collapse-minor-modes` aktiviert (Emacs 31) — faltet die vielen Minor-Mode-Indikatoren zu einem aufklappbaren Eintrag
- `org-replace-disputed-keys` auf `t` gesetzt, bevor org je geladen wird; windmove behält damit `S-<arrows>` (`lisp/my-windows.el`)
- Rechtschreibprüfung via `jinx` (`M-$`, `C-M-$`, `C-c s n/p/a`), aktiv in `text-mode` und `prog-mode`. Läuft über Enchants **AppleSpell**-Provider, also die macOS-Systemprüfung: gelernte Wörter teilen sich `~/Library/Spelling/LocalDictionary` mit allen anderen macOS-Apps
  - Benötigt `brew install enchant` **und** `~/.config/enchant/enchant.ordering` mit `*:AppleSpell,aspell` — Homebrew zieht aspell als Abhängigkeit mit, und Enchant bevorzugt aspell sonst. Die Datei liegt außerhalb des Repos und ist nicht versioniert
  - `jinx-languages` bewusst auf `"en de"` statt `"en_US de_DE"`: AppleSpell registriert nur die generischen Tags, aspell zusätzlich `en_US`, und Enchant bevorzugt den exakten Treffer — `en_US` würde also unbemerkt wieder bei aspell landen
  - Navigation auf eigenem `C-c s`-Präfix statt auf `M-n`/`M-p` in der `jinx-mode-map`: dort kollidierten sie in prog-mode mit den Flymake-Bindings, und zwischen zwei Minor-Mode-Maps entscheidet die Ladereihenfolge. `jinx-next`/`jinx-previous` sind ab Werk nur in `jinx-overlay-map` erreichbar, also erst wenn der Punkt schon auf einem markierten Wort steht
  - Die Tags binden nur den Provider: bei nicht gesetztem `NSPreferredSpellServerLanguage` (macOS-Default) erkennt AppleSpell die Sprache selbst, gemischter Text funktioniert dadurch ohne Umschalten

### Remove

- `yaml-mode` als direkte Abhängigkeit entfernt — Emacs routet `.yaml`/`.yml` ab Werk auf `yaml-ts-mode-maybe`. Nur `Taskfile` (ohne Endung) braucht noch einen expliziten `auto-mode-alist`-Eintrag. Das Paket bleibt als transitive Abhängigkeit von `kubel` installiert
- `elixir-ts-mode` aus der Paketliste entfernt — seit Emacs 30.1 built-in (zusammen mit `heex-ts-mode`), war ohnehin nie aus ELPA installiert
- `smartparens` aus der Paketliste entfernt
- `dockerfile-ts-mode`-Block entfernt: `auto-mode-alist` deckt `Dockerfile` bereits ab

### Docs

- README: neuer Abschnitt "Nach dem ersten Start" mit den manuellen Schritten, die nicht automatisch laufen. `M-x nerd-icons-install-fonts` war bislang **nur** als Kommentar in `lisp/my-ui.el` dokumentiert und fehlte im README komplett
- README: `pkg-config` und C-Compiler in die Prerequisites aufgenommen — ohne pkg-config fällt jinx beim Modulbau auf `/usr/include/enchant-2` und `/usr/local/lib` zurück, was auf Apple Silicon (Homebrew unter `/opt/homebrew`) fehlschlägt
- README: neuer Abschnitt "Spell Checking (macOS-Rechtschreibprüfung)" mit Setup, Verifikationsbefehlen und den zwei Fallstricken (generische Tags, automatische Spracherkennung)
- README: Keybindings-Sektion "Rechtschreibprüfung (jinx)", `enchant` in den Prerequisites
- README: Emacs 30+ → 31+, File-Structure- und Language-Modes-Tabellen aktualisiert
- README: neue Sektion "LSP & Diagnosen (eglot / flymake)" mit Bindings-Tabelle
- README: Installationshinweis auf bedarfsgesteuerte Grammar-Installation umgestellt
- README: org-Konflikt-Hinweis bei windmove — wird jetzt automatisch aufgelöst statt als manueller Schritt beschrieben

### Notes

- Nicht übernommen: `vc-auto-revert-mode` (Emacs 31) wäre bei bereits aktivem `global-auto-revert-mode` eine echte Teilmenge und damit redundant
- Nicht übernommen: `delete-trailing-whitespace-mode` (Emacs 31) als Ersatz für `ws-butler` — der Built-in räumt den ganzen Buffer auf statt nur berührte Zeilen und erzeugt dadurch Diff-Rauschen
- `flyspell`/`ispell` scheiden auf aktuellem macOS aus: `/System/Library/Spelling/` ist leer, es existiert nur noch `AppleSpell.service` ohne CLI und ohne ispell-kompatible Schnittstelle. Der Weg über Enchant (jinx) ist der einzige, der die Systemprüfung erreicht

## 2026-08-17

### Fix

- `package-vc`-Upgrades kompilieren keine Upstream-`tests/`-Verzeichnisse oder versteckten Entwickler-Hilfsdateien mehr; dadurch verschwinden die irreführenden Fehler zu `combobulate-test-prelude` und `tuareg`
- `agent-shell` und `combobulate` bleiben byte-kompiliert, werden aber wegen ihrer Upstream-Cross-File-Warnungen von der optionalen JIT-Native-Kompilierung ausgenommen
- `acp`, `agent-shell` und `combobulate` folgen jetzt konsistent `:rev :newest`, passend zu `package-vc-upgrade-all`
- `package-upgrade-all` prüft Git-basierte VC-Pakete sequenziell und kompiliert nur tatsächlich geänderte Checkouts; bereits aktuelle VC-Pakete werden nicht mehr dauerhaft als drei ausstehende Upgrades gemeldet

## 2026-04-17 (6)

### Feat

- Terraform: `terraform-mode` (MELPA) für `.tf` und `.tfvars`, eglot + `terraform-ls` (gated auf `executable-find`), Auto-Format on Save via apheleia (`terraform fmt` — apheleia ships den Adapter out-of-the-box)
- Tree-sitter HCL Grammar zu `treesit-language-source-alist` ergänzt — kompiliert beim Start, wartet auf künftigen `hcl-ts-mode` (in Emacs 30 noch nicht vorhanden)
- Ansible: `ansible` Minor-Mode mit Auto-Enable in `yaml-ts-mode` basierend auf Pfad-Pattern (`roles/**/tasks`, `group_vars`, `host_vars`, `inventory`, `playbook*.yml`, `site.yml`) via neuer Helper-Funktion `my/ansible-maybe-enable`
- Jinja2: `jinja2-mode` für `.j2` / `.jinja2` (typisch bei Ansible-Templates)

### Docs

- README: Prerequisites um `terraform-ls` und `terraform` CLI erweitert
- README: Language-Modes-Tabelle um Terraform, Ansible, Jinja2 ergänzt
- README: Neuer Unterabschnitt "Ansible Auto-Detection" mit den Pfad-Mustern

## 2026-04-17 (5)

### Feat

- Window-Navigation: `ace-window` als Drop-in-Replacement für `other-window` auf `M-o` und `C-x o` (Buchstaben-Overlay mit Home-Row-Keys, scope = `frame`)
- Window-Navigation: `windmove` (built-in) auf `S-<left/right/up/down>` für direktionales Springen mit `windmove-wrap-around`
- Neues Modul `lisp/my-windows.el` (konsistent mit modularem Layout)

### Docs

- README: Neue Sektion "Window-Navigation" mit Bindings-Tabelle und Hinweis zum org-mode-Konflikt mit `S-<arrows>`
- README: `lisp/my-windows.el` in File-Structure-Tabelle ergänzt

## 2026-04-17 (4)

### Refactor

- Minibuffer-Stack: `ivy` / `ivy-posframe` / `swiper` / `counsel` / `nerd-icons-ivy-rich` ersetzt durch `vertico` + `vertico-posframe` + `marginalia` + `consult` + `consult-projectile` + `embark` + `embark-consult` (moderne, orthogonale Stack-Architektur auf Basis von `completing-read`)
- Auto-Format: Manuelle `before-save-hook → eglot-format`-Hooks in `elixir-ts-mode` und `python-ts-mode` entfernt; ersetzt durch globales `apheleia-global-mode` (async, formatter-unabhängig)
- Terminal: `multi-term` ersetzt durch `eat` (elisp-nativer ANSI-Terminal-Emulator, 24-bit Colors, echte Mouse-Unterstützung)

### Feat

- `embark-act` (`C-.`) — universelles Actions-Menü auf Minibuffer-Auswahl oder Buffer-Symbol
- `consult-buffer` (`C-x b`) — vereint Buffer + Recentf + Bookmarks + Projectile-Buffer
- `consult-line` (`C-s`), `consult-ripgrep` (`M-s r`), `consult-goto-line` (`M-g g`), `consult-imenu` (`M-g i`) mit Live-Preview
- `apheleia` für async Auto-Format on Save (keine Save-Hiccups mehr bei großen Dateien)
- `combobulate` via `package-vc` (pinned SHA `7fe1ea45a...`) für AST-basierte strukturelle Navigation in allen Tree-sitter Modes (Elixir, Python, YAML, JSON, Nix, TOML, Dockerfile) — Prefix `C-c o`
- `savehist-mode` aktiviert — persistente Minibuffer-Historie über Sessions
- `eat` Terminal: `C-c t` für Session, `M-x eat-project` für Projekt-Scoped

### Remove

- `ivy`, `ivy-posframe`, `swiper`, `counsel`, `nerd-icons-ivy-rich`, `multi-term` aus `use-package`-Deklarationen entfernt (Cleanup der `elpa/`-Dirs via `M-x package-autoremove`)

### Fix (Follow-up)

- `package-check-signature` auf `nil` gesetzt — GNU/NonGNU ELPA GPG-Keyring war nicht gebootstrapt, vertico-posframe (signiert via EDDSA) ließ sich sonst nicht installieren. Siehe Kommentar in `init.el` für Bootstrap-Befehl zur erneuten Aktivierung.
- JSON Tree-sitter Grammar zu `treesit-language-source-alist` ergänzt — combobulate's `json-ts-mode`-Hook triggerte „grammar unavailable" Warning ohne dass `.json`-Dateien offen waren.

### Docs

- README: Keybindings-Tabellen für Vertico/Consult/Embark, Eat Terminal, Combobulate ergänzt
- README: Alte "Ivy Minibuffer"-Sektion entfernt
- README: Prerequisites um `ripgrep` (für `consult-ripgrep`) und Formatter (für `apheleia`) erweitert
- README: Migrations-Hinweis für `M-x package-autoremove` am Ende
- README: "Automatic Features" aktualisiert (Apheleia/Combobulate/Savehist/Vertico-Eintrag)

## 2026-04-17 (3)

### Refactor

- Modulare Struktur: `init.el` von 275 auf ~85 Zeilen reduziert; UI/Completion/Editing/Git/AI in `lisp/my-*.el` ausgelagert (`my-ui`, `my-completion`, `my-editing`, `my-git`, `my-ai`)
- Library-Header mit File-Local-Vars kombiniert in allen `.el`-Dateien (Standard-Emacs-Idiom: `;;; file.el --- Description -*- lexical-binding: t; -*-`)
- `early-init.el`: Anonyme Startup-Lambdas durch benannte `my/restore-startup-settings` ersetzt (Docstring, per `remove-hook` entfernbar)
- `init.el`: Section-Headers (`;;; Version guard`, `;;; Package setup`, `;;; Base settings`, `;;; Modules`) für outline-mode-Navigation
- Kommentar zu `custom.el`-Lade-Reihenfolge präzisiert (Warnung gegen `M-x customize` für Package-Settings)

### Feat

- Emacs-Version-Guard: klarer Fehler beim Start mit Emacs < 30.1 (statt stumm fehlschlagendem `use-package :vc`)
- `Taskfile.yml` für lint / smoke / clean als Dev-Workflow (Dogfooding des Taskfile-Supports)
- `.gitignore`: `*.elc` ergänzt (kein versehentliches Committen von byte-compiled Dateien nach `task lint`)

### Fix

- `shell-maker` und `acp` auf `:defer t` — keine eager load mehr bei Startup (wurden vorher geladen obwohl `agent-shell` deferred ist)
- `diff-hl-flydiff-mode` entfernt — Markierungen updaten jetzt nur bei Save/Magit-Refresh (weniger Hintergrund-Last in großen Repos)

### Docs

- README: File-Structure-Tabelle um alle Module erweitert
- README: Neue `## Development`-Sektion mit Task-Kommandos

## 2026-04-17 (2)

### Feat

- YAML Tree-sitter: `yaml-ts-mode` via `major-mode-remap-alist`, Grammar `ikatyang/tree-sitter-yaml` beim Start kompiliert (greift automatisch für alle `.yml`/`.yaml` und `Taskfile`-Dateien)

### Fix

- `acp` und `agent-shell` via `use-package :vc` mit Commit-Pin installiert (reproduzierbare Builds, kein stummer HEAD-Drift mehr)
- Tree-sitter Grammar-Install in `condition-case` gekapselt — Startup bricht nicht mehr ab bei fehlendem C-Compiler oder Netzwerk-Problem
- LSP-Binary-Pfade (`expert`, `agent`) nur registriert wenn `file-executable-p` → keine toten Eglot-/Agent-Shell-Aufrufe
- `multi-term-program` liest `$SHELL` statt hartes `/bin/zsh` (Portabilität)
- `display-line-numbers-mode` nur in `prog-mode`/`text-mode` (kein Noise in magit/dired/help/treemacs)
- `my/package-install-retry` propagiert Original-Fehler wenn Retry fehlschlägt (vorher stumm geschluckt); Refresh-Flag entfernt (Retry läuft jetzt verlässlich pro Install-Aufruf)
- Backup- und Auto-Save-Verzeichnisse werden beim Start angelegt falls fehlend (verhinderte zuvor stumm übersprungene Backups)
- `exec-path-from-shell` nur im GUI-Emacs (`mac`/`ns`/`x`) aktiv — spart ~650 ms beim Terminal-Start

### Refactor

- `lexical-binding: t` Header in `early-init.el`, `init.el`, `common-dev-modes.el` (vermeidet Closure-Bugs, schnellere Interpretation)
- `custom.el` aus `init.el` ausgelagert; `custom-file` explizit gesetzt — `init.el` enthält jetzt ausschließlich handgeschriebenen Code
- `common-dev-modes.el` nach `lisp/` verschoben und stellt `(provide 'common-dev-modes)` bereit; `init.el` nutzt `require` statt hardkodierten `load`-Pfad (verhindert Warning *„your load-path seems to contain your user-emacs-directory"*)
- `package-vc-install` + `package-vc-selected-packages` Duplikate entfernt — Installation läuft nur noch über `use-package :vc`
- `doom-modeline-height` Override entfernt (Default 25 statt 15 → Icons/Text nicht mehr abgeschnitten)
- `show-paren-mode` Kommentar präzisiert (Abgrenzung zu `smartparens`)
- `find-file-visit-truename` Kommentar präzisiert (Trade-off dokumentiert)
- Docstring auf `file-name-handler-alist-original` ergänzt

### Docs

- README: Kubel korrekt als Kubernetes-UI (nicht Sprach-Mode) eingeordnet
- README: YAML/Taskfile-Tabelle zeigt jetzt Tree-sitter-Status
- README: `custom.el` in File-Structure-Tabelle ergänzt

## 2026-04-17

### Feat

- Nix-Support: `nix-ts-mode` (tree-sitter) via MELPA; Grammar `nix-community/tree-sitter-nix` wird beim Start automatisch kompiliert
- Taskfile-Support: Dateien ohne Extension namens `Taskfile`/`taskfile` werden als YAML erkannt (`.yml`/`.yaml`-Varianten waren bereits durch `yaml-mode` abgedeckt)

## 2026-04-10

### Fix

- eglot/Python: `gc-cons-threshold` nach Startup auf 100 MB statt 800 KB (verhindert permanente GC-Pausen bei großen LSP-Antworten → "reconnected"-Schleife)
- eglot/Python: `read-process-output-max` auf 1 MB gesetzt (Default 4 KB war Flaschenhals für pyright-Kommunikation)
- Manuelle `exec-path`-Einträge durch `exec-path-from-shell` ersetzt — liest das vollständige PATH aus der Login-Shell, damit GUI-Emacs alle Binaries findet (node, pyright-langserver etc.)

## 2026-03-19 (8)

### Refactor

- `~/.emacs` nach `~/.emacs.d/init.el` verschoben (gesamte Config in einem Verzeichnis)
- Tree-sitter Grammars werden beim Start automatisch kompiliert wenn sie fehlen
- `custom-set-variables` Block entfernt (wurde von Emacs verwaltet, wird bei Bedarf neu erzeugt)

### Feat

- TOML-Support via `toml-ts-mode` (tree-sitter, built-in)
- Dockerfile tree-sitter Grammar ergänzt
- `kubel` für Kubernetes-Management (`M-x k8s`)
- `.yaml` Dateien werden jetzt auch von `yaml-mode` erkannt (nicht nur `.yml`)

## 2026-03-19 (7)

### Feat

- Python-Support: `python-ts-mode` (tree-sitter) + `eglot` mit pyright LSP, Auto-Format bei Save
- Dockerfile-Support: `dockerfile-ts-mode` (tree-sitter) für Syntax-Highlighting
- Tree-sitter Grammars für Python und Dockerfile in `treesit-language-source-alist` ergänzt

## 2026-03-19 (6)

### Feat

- `magit` hinzugefügt - Git-Interface (`C-x g` für Status)
- `rainbow-delimiters` hinzugefügt - farbkodierte Klammern nach Verschachtelungstiefe
- `orderless` hinzugefügt - flexibles Completion-Matching (z.B. `str down` findet `String.downcase`)
- `diff-hl` hinzugefügt - Git-Änderungen im Fringe (grün/rot/blau Indikatoren)
- `helpful` hinzugefügt - bessere Help-Buffer (`C-h f/v/k/x`)

## 2026-03-19 (5)

### Refactor

- NeoTree durch Treemacs ersetzt
  - `treemacs-projectile` für automatische Projekt-Erkennung
  - `C-c C-p` öffnet jetzt Treemacs in der Seitenleiste
  - `treemacs-is-never-other-window` verhindert versehentliches Fokussieren
  - NeoTree und `neotree-project-dir` Funktion entfernt

## 2026-03-19 (4)

### Feat

- Cursor AI Agent via `agent-shell` + ACP integriert
  - `C-c a` startet eine Cursor Agent Shell
  - Nutzt native ACP-Schnittstelle (`agent acp`), kein npm Adapter nötig

## 2026-03-19 (3)

### Feat

- Autocompletion mit `corfu` hinzugefügt (automatisches Popup bei der Eingabe)
- `nerd-icons-corfu` für Icons im Completion-Popup
- `cape` für zusätzliche Completion-Quellen (Dateipfade, Buffer-Wörter)
- macOS: Rechte Option-Taste als normaler Modifier für Sonderzeichen (] | ~ @ etc.)

## 2026-03-19 (2)

### Feat

- Elixir-Entwicklung: `elixir.el` neu erstellt mit Expert LSP + Tree-sitter
  - `elixir-ts-mode` für Syntax-Highlighting via Tree-sitter
  - `eglot` + [Expert](https://github.com/elixir-lang/expert) als offizieller Elixir LSP
  - Auto-Format bei Save via `eglot-format`
  - `eglot-ensure` Hook startet LSP automatisch beim Öffnen von Elixir-Dateien

## 2026-03-19

### Bugfixes

- Fix `set-fringe-mode`: prüfte `set-fringe-mode` aber rief `tooltip-mode` auf
- Fix doppeltes `(require 'package)` entfernt
- Fix `display-line-numbers-type` wird jetzt vor `global-display-line-numbers-mode` gesetzt, damit relative Nummern sofort aktiv sind
- Fix doppeltes `(prefer-coding-system 'utf-8)` entfernt
- Fix Tippfehler `'exec-path'` → `'exec-path` (extra Quote am Ende entfernt)
- Fix `common-dev-modes.el`: `mapc`-Aufruf aus `:custom`-Block entfernt (wurde fälschlich als Custom-Variable interpretiert)
- Fix `yaml-mode`: `add-to-list` durch `:mode` im `use-package`-Block ersetzt

### Verbesserungen

- use-package Bootstrap-Code entfernt (`require` und `unless package-installed-p`), da use-package ab Emacs 29 eingebaut ist
- Ungenutzten `elpa-%s` Versionscode entfernt
- `ivy-posframe` Settings in `use-package`-Block konsolidiert, `:after ivy` hinzugefügt
- `swiper` und `counsel` mit `:after ivy` versehen
- `neotree`: `(setq neo-theme 'nerd)` in `:custom` konsolidiert
- `projectile`: `projectile-mode` und Keybinding in `use-package`-Block konsolidiert
- `multi-term`: `multi-term-program` in `:custom` konsolidiert
- `multiple-cursors`: alle `global-set-key` Aufrufe als `:bind` in `use-package` konsolidiert
- `expand-region`: `global-set-key` als `:bind` in `use-package` konsolidiert
- `smartparens`: `:defer` durch `:hook (prog-mode . smartparens-mode)` ersetzt, damit das Paket tatsächlich geladen wird
- Backup-Konfiguration hinzugefügt: Backups landen jetzt in `~/.emacs.d/backups/`, Auto-Saves in `~/.emacs.d/auto-saves/`
- `early-init.el` erstellt für schnelleren Startup (GC-Threshold, file-name-handler, package-enable-at-startup)

### Aufgeräumt

- `elixir.el` und `elixir.el~` gelöscht (komplett auskommentiert, wurde nur leer geladen)
- `common-dev-modes.el~` Backup-Datei gelöscht
- Alte TODO-Kommentare entfernt
- Auskommentierte und redundante Kommentare bereinigt
