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
6. Optionally run the Ansible playbook for your OS

## Structure

Each top-level directory is a Stow package:

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

## Ansible Playbooks

- `ansible/macos.yaml` — Homebrew packages and casks
- `ansible/ubuntu.yaml` — apt/snap packages, cargo tools, NVM, SDKMAN
- `ansible/arch.yaml` — pacman packages, cargo tools

## Re-stow (after pulling changes)

```bash
cd ~/dev/dotfiles
stow --restow --target=$HOME zsh git starship tmux nvim bin
```
