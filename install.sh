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

# --- Stow packages ---
echo "Stowing packages..."
cd "$DOTFILES_DIR"

PACKAGES="zsh git starship tmux nvim bin"

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
    echo "  Stowing hyprland..."
    stow --restow --target="$HOME" hyprland
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
echo ""
echo "Restart your shell or run: source ~/.zshrc"
