# Dotfiles

Cross-platform dotfiles for macOS and Linux (Ubuntu/Arch), managed with [GNU Stow](https://www.gnu.org/software/stow/) and [Ansible](https://www.ansible.com/).

## Quick Start

```bash
git clone https://github.com/marad/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
./install.sh
```

The installer will:
1. Detect your OS (macOS / Ubuntu / Arch)
2. Check for `stow` and `ansible` (offer to install if missing)
3. Ask for your git email and create `~/.gitconfig.local`
4. Back up any existing configs to `~/.dotfiles-backup/<timestamp>/`
5. Symlink all config packages via Stow
6. Generate global instructions for Claude Code, Codex, and Pi
7. Optionally run the Ansible playbook for your OS
8. Clone `workflows` to `~/dev/workflows` and set up its `adw` command

On a new system, run `codex login` before `./install.sh` so the workflows setup can build its container image.

## Structure

Configuration directories are Stow packages; `agent-instructions/` contains hand-edited sources:

| Package | Symlinks to |
|---------|-------------|
| `zsh/` | `~/.zshrc` |
| `git/` | `~/.gitconfig`, `~/.gitignore_global` |
| `starship/` | `~/.config/starship.toml` |
| `tmux/` | `~/.tmux.conf` |
| `nvim/` | `~/.config/nvim/` |
| `bin/` | `~/bin/` |
| `i3/` | `~/.i3/` (Linux only) |

## Machine-Specific Config

- **`~/.zshrc.local`** — sourced at end of `.zshrc` for machine-specific env vars, paths, etc.
- **`~/.gitconfig.local`** — git email and credential helper (created by installer)

## Global agent instructions

Edit `agent-instructions/common.md` for shared rules and `claude.md`, `codex.md`,
or `pi.md` in the same directory for tool/model-specific additions. Empty additions
are fine. These files are maintained by hand; change their wording only when
explicitly requested.

After editing, run:

```bash
sync-agent-instructions
```

The command concatenates the sources without rewriting them. It writes regular
files to `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, and
`~/.pi/agent/AGENTS.md`; edit the sources rather than these generated files.
It also includes `~/.claude/CLAUDE.local.md` in all three outputs when present.
That existing private file and the generated outputs stay outside Git. Run the
same command after editing private context. The Claude addition retains its RTK
import; Codex and Pi additions start empty.

Changed outputs are backed up in `~/.dotfiles-backup/agent-instructions.*/`
as `claude.md`, `codex.md`, and `pi.md`. To restore one, copy its backup to the
corresponding global path. A tool with no prior file has no backup.
`install.sh` also runs the sync. Start a new agent session to load changes
(Pi also supports `/reload`).

To preview without changing installed instructions, generate into a temporary
home directory: `sync-agent-instructions /absolute/path/to/preview`.
Private context is read from that target directory too.

## Ansible Playbooks

- `ansible/macos.yaml` — Homebrew packages and casks
- `ansible/ubuntu.yaml` — apt/snap packages, cargo tools, NVM, SDKMAN
- `ansible/arch.yaml` — pacman packages, cargo tools

## Re-stow (after pulling changes)

```bash
cd ~/dev/dotfiles
stow --restow --target=$HOME zsh git starship tmux nvim
stow --no-folding --restow --target=$HOME bin
```
