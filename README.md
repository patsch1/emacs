# Emacs Configuration

Emacs 30+ config with tree-sitter, LSP, autocompletion, and Cursor AI integration.

## Prerequisites

| Dependency | Purpose | Install |
|---|---|---|
| Nerd Fonts | Icons & Font | [nerdfonts.com](https://www.nerdfonts.com/) (SauceCodePro NF) |
| Expert | Elixir LSP | [Releases](https://github.com/elixir-lang/expert/releases) -> `~/.local/bin/expert` |
| pyright | Python LSP | `pip install pyright` |
| Cursor CLI | AI Agent | `agent login` zur Authentifizierung |
| ripgrep | `consult-ripgrep` | `brew install ripgrep` |
| Formatter | Auto-Format via apheleia | z.B. `brew install black` (Python); `mix format` kommt mit Elixir |
| terraform-ls | Terraform LSP | `brew install hashicorp/tap/terraform-ls` |
| terraform | `terraform fmt` via apheleia | `brew install terraform` |
| eat terminfo | 24-bit Farben in `eat`-Terminal | siehe [Terminal Setup](#terminal-setup-eat-terminfo) |

## Installation

```bash
git clone <repo-url> ~/.emacs.d
```

Emacs starten - Pakete und Tree-sitter Grammars installieren sich automatisch.

### Terminal-Setup (eat terminfo)

`eat` liefert eigene terminfo-Einträge (`eat-truecolor`, `eat-256color`, `eat-color`, `eat-mono`) mit, die nach dem Erst-Install einmalig in `~/.terminfo/` kompiliert werden müssen, damit Shells innerhalb eat sie finden:

```bash
tic -x -o ~/.terminfo ~/.emacs.d/elpa/eat-*/eat.ti
```

Verifizieren:

```bash
infocmp eat-truecolor | head -3
```

Hintergrund: Ohne diesen Schritt fallen Shell-rc-Files mit `TERM`-Checks (`[[ $TERM == xterm* ]] ...`) durch oder Programme beschweren sich über `unknown terminal`. Betrifft vor allem User mit Terminals, die selbst exotische TERMs setzen (z.B. Ghostty: `TERM=xterm-ghostty`) — in eat wird das zwar ohnehin auf `eat-truecolor` überschrieben, die terminfo-DB muss den Eintrag aber kennen.

## File Structure

| File | Purpose |
|---|---|
| `early-init.el` | Startup-Optimierungen (GC, file-handler, benannter Startup-Hook) |
| `init.el` | Core-Setup: Version-Guard, Package-Management, Base-Settings, Module-Loader |
| `custom.el` | Emacs Custom (auto-managed, gitignored) |
| `lisp/my-ui.el` | UI: Font, Line-Numbers, Nerd-Icons, Theme, Treemacs, Modeline, Which-Key, Helpful |
| `lisp/my-completion.el` | Completion: Vertico + Posframe, Orderless, Marginalia, Consult, Embark, Corfu, Cape |
| `lisp/my-editing.el` | Editing: Projectile, Smartparens, Apheleia, WS-Butler, Eat-Terminal, Multiple-Cursors, Expand-Region |
| `lisp/my-git.el` | Git: Magit + diff-hl |
| `lisp/my-windows.el` | Window-Navigation: ace-window + windmove |
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
| `C-s` | `consult-line` (fuzzy search im Buffer) |
| `C-x b` | `consult-buffer` (Buffer + Recentf + Bookmarks) |
| `M-y` | `consult-yank-pop` |
| `M-g g` / `M-g M-g` | `consult-goto-line` |
| `M-g i` | `consult-imenu` |
| `M-g o` | `consult-outline` |
| `M-g m` | `consult-mark` |
| `M-s l` | `consult-line` |
| `M-s r` | `consult-ripgrep` (benötigt `rg`) |
| `M-s g` | `consult-grep` |
| `C-.` | `embark-act` (Action-Menü auf Auswahl/Symbol) |
| `C-h B` | `embark-bindings` |
| `C-c C-p` | Treemacs Sidebar toggle |
| `s-p` (Cmd+P) | Projectile command map |
| `s-p p` | Switch project |
| `s-p f` | Find file in project |

### Window-Navigation

| Key | Action |
|---|---|
| `M-o` | `ace-window` (Buchstaben-Overlay auf jedem Fenster, Sprung in 1 Tastendruck) |
| `C-x o` | `ace-window` (Drop-in-Replacement für eingebautes `other-window`) |
| `S-<left>` / `S-<right>` | windmove links/rechts |
| `S-<up>` / `S-<down>` | windmove hoch/runter |

Hinweise:
- `aw-scope` ist auf `frame` gesetzt — ace-window switcht nur innerhalb des aktuellen Frames. Für Multi-Frame-Switch nutze `C-x 5 o` (`other-frame`).
- Home-Row-Letters für ace-window: `a s d f g h j k l`.
- `S-<arrows>` kollidiert mit `org-mode`. Falls du org aktiv nutzt, setze vor org-Load `(setq org-replace-disputed-keys t)` oder ändere den Modifier in `lisp/my-windows.el`.

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

### Terminal (Eat)

| Key | Action |
|---|---|
| `C-c t` | Eat Terminal starten |
| `M-x eat-project` | Eat im Projekt-Root starten |

### Vertico / Consult / Embark

| Key | Action |
|---|---|
| `TAB` | Auswahl completen |
| `RET` | Auswahl bestaetigen |
| `C-n` / `C-p` | Naechster / Vorheriger Eintrag |
| `M-<` / `M->` | Erster / Letzter Eintrag |
| `C-.` | `embark-act` — Action-Menü |
| `C-;` | `embark-dwim` — Default-Action |
| (in Minibuffer nach `C-.`) | Zeigt Actions wie: open, copy, kill, grep, ... |

### Structural Editing (Combobulate, in Tree-sitter Modes)

| Key | Action |
|---|---|
| `C-c o n` | Next sibling (AST) |
| `C-c o p` | Previous sibling (AST) |
| `C-c o u` | Up to parent |
| `C-c o d` | Down into first child |
| `C-c o C-M-k` | Kill node |
| `?` | Alle Combobulate-Bindings im TS-Buffer |

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
| Terraform | `terraform-mode` (`.tf` / `.tfvars`) | HCL-Grammar installiert (kein `hcl-ts-mode` in Emacs 30) | terraform-ls |
| Ansible | `ansible` Minor-Mode über `yaml-ts-mode` (Pfad-Auto-Detect) | Ja (via YAML) | - |
| Jinja2 | `jinja2-mode` (`.j2` / `.jinja2`) | - | - |

### Ansible Auto-Detection

Der `ansible` Minor-Mode aktiviert sich automatisch in `yaml-ts-mode`, sobald der Dateipfad einem dieser Muster entspricht:

- `**/roles/<name>/{tasks,handlers,vars,defaults,meta}/*.yml`
- `**/group_vars/*.yml`, `**/host_vars/*.yml`, `**/inventory/*.yml`
- `playbook*.yml`, `site.yml`

Für Terraform ruft `apheleia` beim Speichern `terraform fmt` auf (benötigt `terraform` im PATH).

## Automatic Features

- **Minibuffer-Completion** - Vertico (vertikal, posframe) + Marginalia (Annotationen) + Orderless (Fuzzy-Match)
- **In-Buffer-Completion** - Corfu Popup mit Nerd-Icons (orderless matching)
- **Auto-Format on Save** - Apheleia (async, ruft externe Formatter wie `black`, `mix format`, `prettier`, ...)
- **Structural Editing** - Combobulate in Tree-sitter Modes (Prefix: `C-c o`)
- **Rainbow Delimiters** - Farbige Klammern in allen prog-mode Buffern
- **Git Fringe Indicators** - diff-hl zeigt Aenderungen im Fringe
- **Trailing Whitespace** - ws-butler entfernt Whitespace beim Speichern
- **Smart Parens** - Automatisches Klammer-Matching in prog-mode (Non-TS)
- **Which-Key** - Zeigt moegliche Tastenkombinationen nach Prefix
- **Savehist** - Persistente Minibuffer-Historie ueber Sessions

## Theme

Doom Zenburn mit Doom Modeline und Nerd-Icons.

## macOS

Rechte Option-Taste liefert Sonderzeichen (`]`, `|`, `~`, `@` etc.), linke Option bleibt Meta.

## Migrations-Hinweis

Nach Umstellung von Ivy auf Vertico: `M-x package-autoremove` räumt veraltete Ivy-Pakete aus `elpa/` auf (`ivy`, `ivy-posframe`, `swiper`, `counsel`, `nerd-icons-ivy-rich`, `multi-term`, `ivy-rich`).

Combobulate zeigt beim Erst-Install byte-compile Warnings für `combobulate-test-prelude` und `tuareg` (OCaml-Support) — kann ignoriert werden. Die Warnings stammen aus Upstream-Testdateien und betreffen die Laufzeit nicht.
