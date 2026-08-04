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
    backup_if_exists "$HOME/.config/linearmouse"
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
mkdir -p "$HOME/.config/rofi"
mkdir -p "$HOME/.config/systemd/user"
# Ensure ~/.claude and ~/.claude/hooks exist so stow links individual files
# instead of folding (symlinking) the whole directory into the repo. Claude Code
# writes its own state into both, so they must stay real directories.
mkdir -p "$HOME/.claude/hooks"

# --- Stow packages ---
echo "Stowing packages..."
cd "$DOTFILES_DIR"

PACKAGES="zsh git starship tmux nvim bin claude"

for pkg in $PACKAGES; do
    echo "  Stowing $pkg..."
    stow --restow --target="$HOME" "$pkg"
done

# Platform-specific packages
if [ "$OS" == "macos" ]; then
    mkdir -p "$HOME/.config/ghostty"
    echo "  Stowing ghostty..."
    stow --restow --target="$HOME" ghostty
    echo "  Stowing karabiner..."
    stow --restow --target="$HOME" karabiner
    # No mkdir for these two: stow symlinks the whole directory. Karabiner and
    # LinearMouse both save their config by writing a temp file and renaming it
    # over the old one, which would replace a per-file symlink with a real file.
    # Linking the directory keeps their writes inside the repo.
    echo "  Stowing linearmouse..."
    stow --restow --target="$HOME" linearmouse
else
    mkdir -p "$HOME/.config/alacritty"
    echo "  Stowing alacritty..."
    stow --restow --target="$HOME" alacritty
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

# --- Poprawka Pi: ignorowanie klawiszy funkcyjnych protokołu Kitty ---
if command -v pi &>/dev/null; then
    bash "$DOTFILES_DIR/scripts/patch_pi_function_keys.sh"
fi

# --- Ansible (optional) ---
read -p "Run Ansible playbook for $OS? [y/N] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    case "$OS" in
        macos)
            # Casks like karabiner-elements install a .pkg via sudo. Ansible runs
            # without a terminal, so brew's sudo can't prompt for a password. Feed
            # it an askpass helper — Homebrew adds `sudo -A` automatically when
            # SUDO_ASKPASS is set (Library/Homebrew/system_command.rb).
            read -rsp "Enter your macOS login password (for Homebrew casks that need sudo): " sudo_password; echo
            PW_FILE="$(mktemp)"; ASKPASS_HELPER="$(mktemp)"
            chmod 600 "$PW_FILE" "$ASKPASS_HELPER"
            printf '%s\n' "$sudo_password" > "$PW_FILE"
            printf '#!/bin/bash\ncat %q\n' "$PW_FILE" > "$ASKPASS_HELPER"
            chmod 700 "$ASKPASS_HELPER"
            trap 'rm -f "$PW_FILE" "$ASKPASS_HELPER"' EXIT
            unset sudo_password
            SUDO_ASKPASS="$ASKPASS_HELPER" ansible-playbook -i localhost, --connection=local "$DOTFILES_DIR/ansible/macos.yaml"
            ;;
        ubuntu) ansible-playbook -i localhost, --connection=local -K "$DOTFILES_DIR/ansible/ubuntu.yaml" ;;
        arch)   ansible-playbook -i localhost, --connection=local -K "$DOTFILES_DIR/ansible/arch.yaml" ;;
        *)      echo "No playbook available for $OS" ;;
    esac
fi

# --- Poetry (Python package manager) ---
if ! command -v poetry &>/dev/null; then
    echo "Installing poetry..."
    curl -sSL https://install.python-poetry.org | python3 -
    export PATH="$HOME/.local/bin:$PATH"
fi

# --- Notes repository ---
# The hourly auto-commit cron (see ansible/*.yaml) operates on ~/notes, so the
# repo must exist. Cloned over HTTPS so the cron's push reuses the gh CLI
# credential helper (see ~/.gitconfig.local) — no per-machine SSH key needed.
NOTES_DIR="$HOME/notes"
if [ ! -d "$NOTES_DIR" ]; then
    echo "Cloning notes..."
    git clone https://github.com/marad/notes.git "$NOTES_DIR"
fi

# --- SoupaWhisper (voice dictation) ---
# Cloned from our fork, which adds macOS support (sox/pbcopy/osascript
# instead of arecord/xclip/xdotool); upstream is ksred/soupawhisper.
SOUPAWHISPER_DIR="$HOME/dev/soupawhisper"
if [ ! -d "$SOUPAWHISPER_DIR" ]; then
    echo "Cloning soupawhisper..."
    mkdir -p "$HOME/dev"
    git clone https://github.com/marad/soupawhisper.git "$SOUPAWHISPER_DIR"
fi

# onnxruntime (pulled in via faster-whisper) ships prebuilt wheels only for
# Python 3.10-3.13, so the venv must not be created with a newer interpreter
# (e.g. Homebrew's default python3, which is already 3.14).
find_soupawhisper_python() {
    local ver
    for ver in 3.13 3.12 3.11 3.10; do
        if command -v "python$ver" &>/dev/null; then
            echo "python$ver"
            return 0
        fi
    done
    return 1
}

if ! SOUPAWHISPER_PYTHON=$(find_soupawhisper_python); then
    echo "No Python 3.10-3.13 found (required by soupawhisper's onnxruntime). Installing 3.13..."
    case "$OS" in
        macos)  brew install python@3.13 ;;
        ubuntu) sudo apt install -y python3.13 python3.13-venv ;;
        *)
            echo "Install Python 3.13 manually (e.g. from AUR) and re-run."
            exit 1
            ;;
    esac
    SOUPAWHISPER_PYTHON=$(find_soupawhisper_python)
fi

# Seed the config from the template (copied, not stowed: the local copy may
# accumulate private vocabulary that must not land in this public repo)
SOUPAWHISPER_CONFIG="$HOME/.config/soupawhisper/config.ini"
if [ ! -f "$SOUPAWHISPER_CONFIG" ]; then
    mkdir -p "$(dirname "$SOUPAWHISPER_CONFIG")"
    cp "$DOTFILES_DIR/soupawhisper/config.ini.example" "$SOUPAWHISPER_CONFIG"
    echo "Created $SOUPAWHISPER_CONFIG from template."
else
    echo "$SOUPAWHISPER_CONFIG already exists, skipping."
fi

echo "Installing soupawhisper dependencies (using $SOUPAWHISPER_PYTHON)..."
cd "$SOUPAWHISPER_DIR"
poetry env use "$SOUPAWHISPER_PYTHON"
poetry install
cd "$DOTFILES_DIR"

# Autostart: systemd service on Linux, LaunchAgent on macOS
if [ "$OS" != "macos" ]; then
    echo "Enabling soupawhisper systemd service..."
    systemctl --user daemon-reload
    systemctl --user enable soupawhisper.service
else
    echo "Installing soupawhisper LaunchAgent..."
    SOUPAWHISPER_PLIST="$HOME/Library/LaunchAgents/com.marad.soupawhisper.plist"
    # The venv path contains a per-machine hash and python version
    SOUPAWHISPER_VENV_PYTHON=$(cd "$SOUPAWHISPER_DIR" && poetry env info --executable)
    mkdir -p "$HOME/Library/LaunchAgents"
    sed -e "s|__PYTHON__|$SOUPAWHISPER_VENV_PYTHON|g" \
        -e "s|__HOME__|$HOME|g" \
        "$DOTFILES_DIR/soupawhisper/com.marad.soupawhisper.plist.template" \
        > "$SOUPAWHISPER_PLIST"
    launchctl unload "$SOUPAWHISPER_PLIST" 2>/dev/null || true
    launchctl load "$SOUPAWHISPER_PLIST"
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

# --- i3 machine-specific config (Linux only) ---
# The main i3 config ends with `include ~/.config/i3/local.conf`; that file holds
# per-machine bits (monitor xrandr setup, workspace-to-output pins) and is not
# tracked. Seed it from the template so a fresh machine still runs its monitor
# setup at i3 startup. Copied, not stowed: each machine keeps its own edits.
if [ "$OS" != "macos" ]; then
    I3_LOCAL_CONF="$HOME/.config/i3/local.conf"
    if [ ! -f "$I3_LOCAL_CONF" ]; then
        cp "$DOTFILES_DIR/i3/.config/i3/local.conf.example" "$I3_LOCAL_CONF"
        echo "Created $I3_LOCAL_CONF from template — edit it with this machine's monitor setup."
    else
        echo "$I3_LOCAL_CONF already exists, skipping."
    fi
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
echo "  ~/.config/soupawhisper/config.ini - Dictation config; add private vocabulary here (created from template)"
echo ""
echo "Claude Code statusline (context usage) is not wired automatically."
echo "Add to ~/.claude/settings.json:"
echo '  "statusLine": { "type": "command", "command": "bash ~/.claude/hooks/statusline.sh" }'
echo ""
echo "Restart your shell or run: source ~/.zshrc"
