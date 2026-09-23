# Emacs Configuration

Emacs 31+ config with tree-sitter, LSP, autocompletion, and Cursor AI integration.

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
| enchant | Rechtschreibprüfung via `jinx` | `brew install enchant` + siehe [Spell Checking](#spell-checking-macos-rechtschreibprüfung) |
| pkg-config | Baut jinx' C-Modul gegen enchant | `brew install pkg-config` |
| C-Compiler | dito | `xcode-select --install` (Command Line Tools) |

## Installation

```bash
git clone <repo-url> ~/.emacs.d
```

Emacs starten - Pakete installieren sich automatisch.

Tree-sitter-Grammars werden **bei Bedarf** installiert: `treesit-auto-install-grammar`
steht auf `ask`, Emacs fragt also beim ersten Öffnen einer Datei nach, deren Grammar
noch fehlt. Die Bezugsquellen stehen in `treesit-language-source-alist`
(`lisp/common-dev-modes.el`).

### Nach dem ersten Start

Diese Schritte laufen **nicht** automatisch und müssen einmalig von Hand erledigt
werden — auf jedem neuen Rechner erneut:

| Schritt | Wozu | Wann nötig |
|---|---|---|
| `M-x nerd-icons-install-fonts` | Installiert die Nerd-Icons-Symbolschrift. Ohne sie zeigen Treemacs, Dired, Corfu und die Modeline Platzhalter-Kästchen | Immer |
| `tic -x -o ~/.terminfo ~/.emacs.d/elpa/eat-*/eat.ti` | terminfo für das `eat`-Terminal, siehe [Terminal-Setup](#terminal-setup-eat-terminfo) | Bei Nutzung von `C-c t` |
| `~/.config/enchant/enchant.ordering` anlegen | Sonst nutzt jinx aspell statt der macOS-Prüfung, siehe [Spell Checking](#spell-checking-macos-rechtschreibprüfung) | Bei Rechtschreibprüfung |
| `M-x package-autoremove` | Entfernt Pakete, die nicht mehr in `my/package-selected-packages` stehen | Nach Config-Updates |

Automatisch laufen dagegen: Paketinstallation, das Kompilieren von jinx' C-Modul beim
ersten Start (benötigt Compiler und `pkg-config`, siehe Prerequisites) und — nach
Rückfrage — die Installation fehlender Tree-sitter-Grammars.

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

### Spell Checking (macOS-Rechtschreibprüfung)

`jinx` prüft über [Enchant](https://rrthomas.github.io/enchant/), und Enchant bringt
auf macOS einen **AppleSpell-Provider** mit — also genau die Rechtschreibprüfung, die
der Rest des Systems nutzt. Gelernte Wörter landen damit in
`~/Library/Spelling/LocalDictionary` und sind in allen macOS-Apps bekannt, in beide
Richtungen.

```bash
brew install enchant
```

Homebrew zieht `aspell` als harte Abhängigkeit mit, und Enchant bevorzugt aspell.
Damit AppleSpell gewinnt, braucht es eine Ordering-Datei:

```bash
mkdir -p ~/.config/enchant
printf '*:AppleSpell,aspell\n' > ~/.config/enchant/enchant.ordering
```

> Diese Datei liegt außerhalb des Repos und wird **nicht** mitversioniert — auf einem
> neuen Rechner ist der Schritt zu wiederholen.

Verifizieren:

```bash
enchant-lsmod-2                # muss "AppleSpell (AppleSpell Provider)" listen
enchant-lsmod-2 -lang en       # -> en (AppleSpell)
enchant-lsmod-2 -lang de       # -> de (AppleSpell)
```

Zwei Eigenheiten, die leicht verwirren:

- **Generische Sprach-Tags sind Absicht.** `jinx-languages` steht auf `"en de"`, nicht
  auf `"en_US de_DE"`. AppleSpell registriert nur `en` und `de`; aspell registriert
  zusätzlich `en_US`. Da Enchant den exakten Tag bevorzugt, würde `en_US` still und
  leise wieder bei aspell landen.
- **Die Sprache wählt macOS selbst.** Solange `NSPreferredSpellServerLanguage` nicht
  gesetzt ist (Default: „Automatisch nach Sprache"), erkennt AppleSpell die Sprache
  pro Wort. Die Tags binden also den Provider, nicht das Wörterbuch — gemischt
  deutsch-englischer Text funktioniert dadurch ohne Umschalten.

Das C-Modul von jinx (`jinx-mod.dylib`) wird beim ersten Start automatisch übersetzt.
Dafür braucht es einen C-Compiler **und** `pkg-config`: ohne pkg-config fällt jinx auf
fest verdrahtete Pfade (`/usr/include/enchant-2`, `/usr/local/lib`) zurück, die auf
Apple Silicon ins Leere zeigen — Homebrew liegt dort unter `/opt/homebrew`. Der Bau
schlägt dann fehl, mit `Jinx: pkgconf or pkg-config not found` im Puffer
`*jinx module compilation*`.

## File Structure

| File | Purpose |
|---|---|
| `early-init.el` | Startup-Optimierungen (GC-Threshold beim Start hoch, zur Laufzeit 16 MB; file-handler, benannter Startup-Hook) |
| `init.el` | Core-Setup: Version-Guard (31.1+), Base-Settings, Module-Loader |
| `custom.el` | Emacs Custom (auto-managed, gitignored) |
| `lisp/my-packages.el` | Deklarative Paketliste, Archive und sichere sequenzielle VC-Upgrades |
| `lisp/my-ui.el` | UI: Font, Line-Numbers, Nerd-Icons, Theme, Treemacs, Modeline, Which-Key, Helpful |
| `lisp/my-completion.el` | Completion: Vertico + Posframe, Orderless, Marginalia, Consult, Embark, Corfu, Cape |
| `lisp/my-editing.el` | Editing: Projectile, Dired, Electric-Pair, Apheleia, WS-Butler, Jinx, Eat-Terminal, Multiple-Cursors, Expand-Region |
| `lisp/my-git.el` | Git: Magit, diff-hl, Ediff (Single-Frame-Layout) |
| `lisp/my-windows.el` | Window-Navigation: ace-window + windmove |
| `lisp/my-ai.el` | AI Agent Shell (Cursor CLI via ACP, jeweils neueste Revision) |
| `lisp/common-dev-modes.el` | Tree-sitter-Setup, eglot/flymake-Bindings, Sprach-Modi (Elixir, Python, Dockerfile, Nix, YAML/Taskfile, Markdown) + Kubernetes-UI (`kubel`) |
| `test/my-packages-test.el` | ERT-Tests für Paket-Auswahl, Archive und VC-Statusprüfung |
| `Taskfile.yml` | Dev-Workflow: lint / smoke / clean |

## Development

Setzt [Task](https://taskfile.dev/) voraus (`brew install go-task`).

| Kommando | Zweck |
|---|---|
| `task` oder `task --list` | Verfügbare Tasks auflisten |
| `task lint` | Byte-compile aller `.el`-Dateien |
| `task test` | ERT-Tests für die Paketverwaltung ausführen |
| `task smoke` | Batch-Load von `init.el` prüfen |
| `task clean` | Nur `.elc`-Dateien der eigenen Konfiguration entfernen |

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
- `S-<arrows>` kollidiert grundsätzlich mit `org-mode`. `lisp/my-windows.el` setzt deshalb `org-replace-disputed-keys` auf `t`, bevor org je geladen wird — org weicht damit auf `C-c C-S-<arrows>` aus, windmove behält `S-<arrows>`.

### LSP & Diagnosen (eglot / flymake)

Beide Keymaps sind buffer-lokal — die Bindings existieren nur dort, wo tatsächlich
ein Sprachserver läuft bzw. `flymake-mode` aktiv ist.

| Key | Action |
|---|---|
| `C-c l r` | `eglot-rename` |
| `C-c l a` | `eglot-code-actions` |
| `C-c l f` | `eglot-format` |
| `C-c l d` | `eldoc-doc-buffer` (Doku in eigenem Buffer) |
| `C-c l i` | `eglot-find-implementation` |
| `C-c l t` | `eglot-find-typeDefinition` |
| `C-c l R` | `eglot-reconnect` |
| `C-c l q` | `eglot-shutdown` |
| `M-n` / `M-p` | Nächster / voriger Flymake-Fehler |
| `C-c e l` | Diagnosen im Buffer |
| `C-c e p` | Diagnosen im Projekt |
| `C-c e c` | `consult-flymake` (durchsuchbare Übersicht) |

`M-.` (`xref-find-definitions`) und `M-?` (`xref-find-references`) sind Emacs-Defaults
und funktionieren mit eglot ohne zusätzliche Konfiguration.

### Rechtschreibprüfung (jinx)

| Key | Action |
|---|---|
| `M-$` | `jinx-correct` — korrigiert **alle** Fundstellen im sichtbaren Fenster, der Punkt muss nicht auf dem Wort stehen |
| `C-c s a` | `jinx-correct-all` — ganzer Buffer (oder aktive Region), mit Fortschritt `(3 of 12)` |
| `C-c s n` / `C-c s p` | Zur nächsten / vorigen Fundstelle springen |
| `C-M-$` | `jinx-languages` — Sprachen für den aktuellen Buffer wechseln |
| `M-x jinx-correct-word` | Wort **vor dem Punkt** korrigieren, auch wenn es nicht als falsch markiert ist |

Aktiv in `text-mode` und `prog-mode`; in Code werden nur Kommentare, Docstrings und
Strings geprüft (`jinx-include-faces`), Bezeichner bleiben unangetastet.

`jinx-next` / `jinx-previous` sind ab Werk nur in `jinx-overlay-map` gebunden, greifen
also erst, wenn der Punkt bereits auf einem markierten Wort steht — deshalb zusätzlich
das `C-c s`-Präfix. Bewusst **nicht** auf `M-n`/`M-p` in der `jinx-mode-map`: dort
kollidierten sie in prog-mode mit Flymake, und zwischen zwei Minor-Mode-Maps entscheidet
die Ladereihenfolge. Da `repeat-mode` aktiv ist, genügen nach dem ersten Sprung die
blanken Tasten `n`, `p` und `$`.

`jinx-correct-all` setzt vorher eine Mark — `C-u C-SPC` bringt dich zurück.

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
| Dockerfile | `dockerfile-ts-mode` (built-in `auto-mode-alist`) | Ja | - |
| HEEx | `heex-ts-mode` (built-in) | Ja | - |
| TOML | `toml-ts-mode` | Ja | - |
| YAML | `yaml-ts-mode` (built-in `auto-mode-alist`) | Ja | - |
| Taskfile | `yaml-ts-mode` (`Taskfile.yml` / `Taskfile`) | Ja | - |
| Nix | `nix-ts-mode` | Ja | - |
| Markdown | `markdown-mode` / `gfm-mode` | - | - |
| JSON | `json-ts-mode` (built-in) | Ja | - |
| Terraform | `terraform-mode` (`.tf` / `.tfvars`) | HCL-Grammar konfiguriert (kein `hcl-ts-mode` in Emacs 31) | terraform-ls |
| Ansible | `ansible-mode` über `yaml-ts-mode` (Pfad-Auto-Detect) | Ja (via YAML) | - |
| Jinja2 | `jinja2-mode` (`.j2` / `.jinja2`) | - | - |

### Ansible Auto-Detection

Der `ansible-mode` aktiviert sich automatisch in `yaml-ts-mode`, sobald der Dateipfad einem dieser Muster entspricht:

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
- **Electric Pair** - Automatisches Klammer-Matching in prog-mode (built-in; paart seit Emacs 31 auch mehrzeichige Delimiter)
- **Which-Key** - Zeigt moegliche Tastenkombinationen nach Prefix
- **Savehist** - Persistente Minibuffer-Historie ueber Sessions, inkl. `kill-ring` und Such-Ringe
- **Recentf + Save Place** - Zuletzt geöffnete Dateien und Cursorpositionen bleiben erhalten
- **Auto Revert** - Extern geänderte Dateien und Verzeichnisse aktualisieren sich automatisch
- **Winner + Repeat** - Fensterlayouts rückgängig machen und Befehlsfolgen leichter wiederholen
- **Tree-sitter Modes** - `treesit-enabled-modes` schaltet die eingebauten TS-Modes frei; Grammars werden bei Bedarf nachinstalliert (`treesit-auto-install-grammar`)
- **Dired** - `dired-dwim-target`, Puffer-Wiederverwendung beim Absteigen, rekursives Kopieren
- **Ediff** - Single-Frame-Layout, Buffer nebeneinander, Fensterlayout wird beim Beenden via `winner-undo` wiederhergestellt
- **Base-Defaults** - `y`/`n` statt `yes`/`no`, `delete-selection-mode`, Spaces statt Tabs, `context-menu-mode`, Pixel-Scrolling
- **Rechtschreibprüfung** - jinx prüft nur den sichtbaren Bereich, via Enchant/AppleSpell gegen die macOS-Systemprüfung

## Theme

Doom Zenburn mit Doom Modeline und Nerd-Icons.

## macOS

Rechte Option-Taste liefert Sonderzeichen (`]`, `|`, `~`, `@` etc.), linke Option bleibt Meta.

## Package Management

Die direkten Abhängigkeiten stehen explizit in `lisp/my-packages.el`. Dadurch
kennt `package-autoremove` den Unterschied zwischen benötigten Paketen und
veralteten Resten. Die früheren Ivy/Counsel-Pakete wurden nach der Umstellung
auf Vertico entfernt.

Bei VC-Paketen ignoriert die Konfiguration `tests/` und versteckte
Entwickler-Hilfsdateien während der rekursiven Paketkompilierung. Dadurch
benötigen `acp`, `agent-shell` und `combobulate` keine reinen
Entwickler-/Test-Abhängigkeiten beim Installieren oder Aktualisieren.

`M-x package-upgrade-all` prüft VC-Pakete sequenziell per `git fetch` und
vergleicht `HEAD` mit dem jeweiligen Upstream. Die Fetches laufen asynchron
mit einem Timeout von 30 Sekunden. Bereits aktuelle VC-Pakete werden dadurch
weder fälschlich als Upgrade gezählt noch erneut kompiliert.
