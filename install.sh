#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# --- OS Detection ---
detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)
            if [ -f /etc/arch-release ]; then
                echo "arch"
            elif [ -f /etc/debian_version ]; then
                echo "ubuntu"
            else
                echo "linux"
            fi
            ;;
        *) echo "unknown" ;;
    esac
}

OS=$(detect_os)
echo "Detected OS: $OS"

# --- Check prerequisites ---
check_command() {
    if ! command -v "$1" &>/dev/null; then
        echo "$1 is not installed."
        read -p "Install $1? [y/N] " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            case "$OS" in
                macos)  brew install "$1" ;;
                ubuntu) sudo apt install -y "$1" ;;
                arch)   sudo pacman -S --noconfirm "$1" ;;
            esac
        else
            echo "Cannot continue without $1. Exiting."
            exit 1
        fi
    fi
}

check_command stow
check_command ansible

# --- Git email ---
if [ ! -f "$HOME/.gitconfig.local" ]; then
    read -p "Enter your git email address: " git_email
    if [ -n "$git_email" ]; then
        cat > "$HOME/.gitconfig.local" <<EOF
[user]
    email = $git_email

[credential "https://github.com"]
    helper =
    helper = !$(command -v gh) auth git-credential
[credential "https://gist.github.com"]
    helper =
    helper = !$(command -v gh) auth git-credential
EOF
        echo "Created ~/.gitconfig.local with email: $git_email"
    fi
else
    echo "~/.gitconfig.local already exists, skipping git email setup."
fi

# --- Claude private context ---
# CLAUDE.md is public (stowed); the sensitive bits live in ~/.claude/CLAUDE.local.md,
# which CLAUDE.md imports but which is never committed. Seed it from the template.
if [ ! -f "$HOME/.claude/CLAUDE.local.md" ]; then
    mkdir -p "$HOME/.claude"
    cp "$DOTFILES_DIR/claude/CLAUDE.local.md.example" "$HOME/.claude/CLAUDE.local.md"
    echo "Created ~/.claude/CLAUDE.local.md from template — edit it with your private context."
else
    echo "~/.claude/CLAUDE.local.md already exists, skipping."
fi

# --- Backup existing configs (only real files, skip symlinks) ---
backup_if_exists() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        mkdir -p "$BACKUP_DIR"
        local rel_path="${target#$HOME/}"
        local backup_path="$BACKUP_DIR/$rel_path"
        mkdir -p "$(dirname "$backup_path")"
        mv "$target" "$backup_path"
        echo "Backed up $target -> $backup_path"
    fi
}

echo "Checking for existing configs to back up..."
backup_if_exists "$HOME/.zshrc"
backup_if_exists "$HOME/.gitconfig"
backup_if_exists "$HOME/.gitignore_global"
backup_if_exists "$HOME/.tmux.conf"
backup_if_exists "$HOME/.config/starship.toml"
backup_if_exists "$HOME/.config/nvim"
backup_if_exists "$HOME/.claude/CLAUDE.md"

if [ "$OS" == "macos" ]; then
    backup_if_exists "$HOME/.config/karabiner"
else
    backup_if_exists "$HOME/.config/i3"
    backup_if_exists "$HOME/.config/hypr"
    backup_if_exists "$HOME/.config/waybar"
fi

# --- Ensure directories exist (prevent stow from symlinking whole dirs) ---
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/i3"
mkdir -p "$HOME/.config/hypr"
mkdir -p "$HOME/.config/waybar"
mkdir -p "$HOME/.config/picom"
mkdir -p "$HOME/.config/alacritty"
mkdir -p "$HOME/.config/rofi"
mkdir -p "$HOME/.config/systemd/user"
# Ensure ~/.claude exists so stow links the single CLAUDE.md file instead of
# folding (symlinking) the whole directory into the repo.
mkdir -p "$HOME/.claude"

# --- Stow packages ---
echo "Stowing packages..."
cd "$DOTFILES_DIR"

PACKAGES="zsh git starship tmux nvim bin alacritty claude"

for pkg in $PACKAGES; do
    echo "  Stowing $pkg..."
    stow --restow --target="$HOME" "$pkg"
done

# Platform-specific packages
if [ "$OS" == "macos" ]; then
    echo "  Stowing karabiner..."
    stow --restow --target="$HOME" karabiner
else
    echo "  Stowing i3..."
    stow --restow --target="$HOME" i3
    echo "  Stowing picom..."
    stow --restow --target="$HOME" picom
    echo "  Stowing rofi..."
    stow --restow --target="$HOME" rofi
    echo "  Stowing hyprland..."
    stow --restow --target="$HOME" hyprland
    echo "  Stowing systemd..."
    stow --restow --target="$HOME" systemd
fi

echo "All packages stowed."

# --- Ansible (optional) ---
read -p "Run Ansible playbook for $OS? [y/N] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    case "$OS" in
        macos)  ansible-playbook -i localhost, --connection=local "$DOTFILES_DIR/ansible/macos.yaml" ;;
        ubuntu) ansible-playbook -i localhost, --connection=local "$DOTFILES_DIR/ansible/ubuntu.yaml" ;;
        arch)   ansible-playbook -i localhost, --connection=local "$DOTFILES_DIR/ansible/arch.yaml" ;;
        *)      echo "No playbook available for $OS" ;;
    esac
fi

# --- Poetry (Python package manager) ---
if ! command -v poetry &>/dev/null; then
    echo "Installing poetry..."
    curl -sSL https://install.python-poetry.org | python3 -
    export PATH="$HOME/.local/bin:$PATH"
fi

# --- SoupaWhisper (voice dictation) ---
SOUPAWHISPER_DIR="$HOME/dev/soupawhisper"
if [ ! -d "$SOUPAWHISPER_DIR" ]; then
    echo "Cloning soupawhisper..."
    mkdir -p "$HOME/dev"
    git clone https://github.com/ksred/soupawhisper.git "$SOUPAWHISPER_DIR"
fi

echo "Installing soupawhisper dependencies..."
cd "$SOUPAWHISPER_DIR" && poetry install
cd "$DOTFILES_DIR"

# Enable soupawhisper systemd service (Linux only)
if [ "$OS" != "macos" ]; then
    echo "Enabling soupawhisper systemd service..."
    systemctl --user daemon-reload
    systemctl --user enable soupawhisper.service
fi

# --- i3 resume-reflow hook (Linux only) ---
# Rebuilds the i3 layout on resume so a suspend/resume display flap does not
# leave windows with missing gaps or stale stacking (see system-sleep/ and
# bin/bin/i3-reflow-all).
if [ "$OS" != "macos" ]; then
    echo "Installing i3 resume-reflow system-sleep hook (requires sudo)..."
    sudo install -m 755 "$DOTFILES_DIR/system-sleep/i3-resume-reflow" \
        /usr/lib/systemd/system-sleep/i3-resume-reflow
fi

# --- Make bin scripts executable ---
chmod +x "$HOME/bin/"* 2>/dev/null || true

# --- Summary ---
echo ""
echo "========================================"
echo "  Dotfiles installed successfully!"
echo "========================================"
echo ""
echo "Remember to create/edit these files for machine-specific config:"
echo "  ~/.zshrc.local      - Machine-specific shell config"
echo "  ~/.gitconfig.local  - Git email and credentials (already created if prompted)"
echo "  ~/.config/i3/local.conf  - i3 machine-specific config (monitor setup, etc.)"
echo "  ~/.config/hypr/local.conf - Hyprland machine-specific config (monitors, etc.)"
echo "  ~/.claude/CLAUDE.local.md - Private/company context for Claude (created from template)"
echo ""
echo "Restart your shell or run: source ~/.zshrc"
