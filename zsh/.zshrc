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
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$PATH"
if [[ "$OS" == "linux" ]]; then
    export PATH="/opt/nvim-linux-x86_64/bin:$PATH"
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
alias cc="claude"
alias ccy="claude --dangerously-skip-permissions"

# Linux clipboard aliases
if [[ "$OS" == "linux" ]]; then
    if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
        alias pbcopy='wl-copy'
        alias pbpaste='wl-paste'
    else
        alias pbcopy='xsel --clipboard --input'
        alias pbpaste='xsel --clipboard --output'
    fi
fi

# --- Zoxide (smart cd) ---
if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
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
