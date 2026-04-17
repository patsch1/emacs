# Changelog

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
