# Emacs Configuration

Emacs 30+ config with tree-sitter, LSP, autocompletion, and Cursor AI integration.

## Prerequisites

| Dependency | Purpose | Install |
|---|---|---|
| Nerd Fonts | Icons & Font | [nerdfonts.com](https://www.nerdfonts.com/) (SauceCodePro NF) |
| Expert | Elixir LSP | [Releases](https://github.com/elixir-lang/expert/releases) -> `~/.local/bin/expert` |
| pyright | Python LSP | `pip install pyright` |
| Cursor CLI | AI Agent | `agent login` zur Authentifizierung |

## Installation

```bash
git clone <repo-url> ~/.emacs.d
```

Emacs starten - Pakete und Tree-sitter Grammars installieren sich automatisch.

## File Structure

| File | Purpose |
|---|---|
| `early-init.el` | Startup-Optimierungen (GC, file-handler, benannter Startup-Hook) |
| `init.el` | Core-Setup: Version-Guard, Package-Management, Base-Settings, Module-Loader |
| `custom.el` | Emacs Custom (auto-managed, gitignored) |
| `lisp/my-ui.el` | UI: Font, Line-Numbers, Nerd-Icons, Theme, Treemacs, Modeline, Which-Key, Helpful |
| `lisp/my-completion.el` | Completion: Ivy + Posframe + Swiper/Counsel, Orderless, Corfu, Cape |
| `lisp/my-editing.el` | Editing: Projectile, Smartparens, Multi-Term, WS-Butler, Multiple-Cursors, Expand-Region |
| `lisp/my-git.el` | Git: Magit + diff-hl |
| `lisp/my-ai.el` | AI Agent Shell (Cursor CLI via ACP, pinned revisions) |
| `lisp/common-dev-modes.el` | Sprach-Modi (Elixir, Python, Dockerfile, Nix, YAML/Taskfile, Markdown) + Kubernetes-UI (`kubel`) |
| `Taskfile.yml` | Dev-Workflow: lint / smoke / clean |

## Development

Setzt [Task](https://taskfile.dev/) voraus (`brew install go-task`).

| Kommando | Zweck |
|---|---|
| `task` oder `task --list` | Verfügbare Tasks auflisten |
| `task lint` | Byte-compile aller `.el`-Dateien |
| `task smoke` | Batch-Load von `init.el` prüfen |
| `task clean` | `.elc`-Dateien entfernen |

## Keybindings

### Navigation & Search

| Key | Action |
|---|---|
| `C-s` | Swiper (fuzzy search in buffer) |
| `C-c C-p` | Treemacs Sidebar toggle |
| `s-p` (Cmd+P) | Projectile command map |
| `s-p p` | Switch project |
| `s-p f` | Find file in project |

### Treemacs (Sidebar)

| Key | Action |
|---|---|
| Click | Ordner auf-/zuklappen, Datei oeffnen |
| `RET` / `TAB` | Datei oeffnen / Ordner toggle |
| `c f` | Neue Datei |
| `c d` | Neuer Ordner |
| `d` | Loeschen |
| `R` | Umbenennen |
| `r` | Refresh |
| `q` | Schliessen |
| `?` | Alle Keybindings |

### Multiple Cursors

| Key | Action |
|---|---|
| `C-c m` | Mark all (DWIM) |
| `C-M-a` | Mark all like this |
| `C-M-n` | Mark next like this |
| `C-M-p` | Mark previous like this |
| `C-M->` | Skip to next like this |
| `C-M-<` | Skip to previous like this |
| `C-M-c` | Edit lines (cursor on each line of region) |
| `C-M-l` | Expand region |
| `C-g` | Beenden |

### Git (Magit)

| Key | Action |
|---|---|
| `C-x g` | Magit Status |

In Magit Status:

| Key | Action |
|---|---|
| `s` | Stage |
| `u` | Unstage |
| `c c` | Commit |
| `P p` | Push |
| `F p` | Pull |
| `b b` | Branch wechseln |
| `l l` | Log |
| `q` | Schliessen |

### Completion (Corfu)

| Key | Action |
|---|---|
| (automatisch) | Popup nach 0.2s / 1 Zeichen |
| `C-n` / `C-p` | Naechster / Vorheriger Eintrag |
| `RET` | Auswahl bestaetigen |
| `C-g` | Popup schliessen |

### Help (Helpful)

| Key | Action |
|---|---|
| `C-h f` | Describe function |
| `C-h v` | Describe variable |
| `C-h k` | Describe keybinding |
| `C-h x` | Describe command |

### AI Agent (Cursor via ACP)

| Key | Action |
|---|---|
| `C-c a` | Agent Shell starten (Cursor auswaehlen) |

### Kubernetes (kubel)

| Key | Action |
|---|---|
| `M-x k8s` | Kubel starten |
| `?` | Alle Keybindings im kubel Buffer |

### Ivy Minibuffer

| Key | Action |
|---|---|
| `TAB` | Auswahl bestaetigen |
| `C-j` / `C-k` | Naechster / Vorheriger Eintrag |
| `C-l` | Auswahl bestaetigen (alt) |
| `C-d` | Buffer loeschen (im Switch-Buffer) |

## Language Modes

| Language | Mode | Tree-sitter | LSP |
|---|---|---|---|
| Elixir | `elixir-ts-mode` | Ja | Expert |
| Python | `python-ts-mode` | Ja | pyright |
| Dockerfile | `dockerfile-ts-mode` | Ja | - |
| TOML | `toml-ts-mode` | Ja | - |
| YAML | `yaml-ts-mode` (via Remap, Fallback `yaml-mode`) | Ja | - |
| Taskfile | `yaml-ts-mode` (`Taskfile.yml` / `Taskfile`) | Ja | - |
| Nix | `nix-ts-mode` | Ja | - |
| Markdown | `markdown-mode` / `gfm-mode` | - | - |
| JSON | `json-ts-mode` (built-in) | Ja | - |

## Automatic Features

- **Autocompletion** - Corfu Popup mit Nerd-Icons (orderless matching)
- **Auto-Format on Save** - Elixir und Python (via eglot)
- **Rainbow Delimiters** - Farbige Klammern in allen prog-mode Buffern
- **Git Fringe Indicators** - diff-hl zeigt Aenderungen im Fringe
- **Trailing Whitespace** - ws-butler entfernt Whitespace beim Speichern
- **Smart Parens** - Automatisches Klammer-Matching in prog-mode
- **Which-Key** - Zeigt moegliche Tastenkombinationen nach Prefix

## Theme

Doom Zenburn mit Doom Modeline und Nerd-Icons.

## macOS

Rechte Option-Taste liefert Sonderzeichen (`]`, `|`, `~`, `@` etc.), linke Option bleibt Meta.
