# Changelog

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
