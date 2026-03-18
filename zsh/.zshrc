# Cross-platform zsh configuration

# OS detection
case "$(uname -s)" in
    Darwin) OS="macos" ;;
    Linux)  OS="linux" ;;
esac

# --- Homebrew (macOS only) ---
if [[ "$OS" == "macos" ]]; then
    eval "$($HOME/homebrew/bin/brew shellenv)"
fi

# --- PATH ---
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
if [[ "$OS" == "linux" ]]; then
    export PATH="/opt/nvim-linux64/bin:$PATH"
fi

# --- Editor ---
export EDITOR=nvim

# --- History ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# --- Completions ---
autoload -Uz compinit && compinit

# --- Aliases ---
alias ls="eza --icons --git"
alias ll="eza --icons --git -lah"
alias grep="rg"
alias cat="bat"
alias ssha='eval $(ssh-agent) && ssh-add'

# Linux clipboard aliases
if [[ "$OS" == "linux" ]]; then
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
fi

# --- Jumper (https://github.com/marad/jumper) ---
if (( $+commands[jumper] )); then
    jumpLocation() {
        if [ -z "$@" ]; then
            selected=$(jumper list | fzf --ansi | awk -F'|' '{gsub(/^\s+/, "", $2); print $2}')
            cd "$selected"
        else
            selected=$(jumper get "$@")
            cd "$selected"
        fi
    }
    alias jg="jumpLocation"
fi

# --- Starship prompt ---
eval "$(starship init zsh)"

# --- NVM (conditional) ---
if [[ -d "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# --- SDKMAN (conditional, must be at end before local) ---
if [[ -d "$HOME/.sdkman" ]]; then
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# --- Machine-specific config ---
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
