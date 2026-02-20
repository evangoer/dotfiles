# ~/.zshrc - Minimal, resilient shell configuration

#=============================================================================
# SECTION 1: Always works (no external dependencies)
#=============================================================================

# History
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks

# Basic options
setopt auto_cd
setopt interactive_comments

# Completions (built into zsh)
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Key bindings
bindkey -e  # emacs mode (or -v for vim)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

#=============================================================================
# SECTION 2: mise-managed tools (resilient - survives OS upgrades)
#=============================================================================

# mise activation (provides node, python, nvim, starship, fzf, uv)
if [[ -f /opt/local/bin/mise ]]; then
  eval "$(/opt/local/bin/mise activate zsh)"
fi

# Starship prompt (installed via mise)
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# fzf integration (installed via mise)
if command -v fzf &> /dev/null; then
  eval "$(fzf --zsh)"
fi

alias vim=nvim

#=============================================================================
# SECTION 3: Optional enhancements (may break after OS upgrade, non-critical)
#=============================================================================

# Misc user tools not managed by mise or ports (Claude Code)
if [[ -d ~/.local/bin ]]; then
  export PATH="/Users/evan/.local/bin:$PATH"
fi

# MacPorts (rebuild after OS upgrades with: sudo port selfupdate && sudo port upgrade outdated)
if [[ -d /opt/local/bin ]]; then
  export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
fi

# zsh plugins (cloned to ~/.zsh/, no package manager dependency)
[[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#=============================================================================
# SECTION 4: Local customizations
#=============================================================================

# Machine-specific config (not checked into dotfiles)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
