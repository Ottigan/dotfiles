eval "$(~/.local/bin/mise activate zsh)"
eval "$(zoxide init zsh)"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
plugins=(zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# XDG base directories.
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_PICTURES_DIR="$HOME/Pictures"
export XDG_STATE_HOME="$HOME/.local/state"

# Make sure this stuff is in the path.
export PATH="$HOME/.nvim/bin:$PATH"  # Neovim
export PATH="$HOME/.cargo/bin:$PATH" # Cargo
export PATH="$HOME/.local/bin:$PATH" # Local scripts
export PATH="$HOME/go/bin:$PATH"     # Go binaries.

# Use neovim as the default editor.
export EDITOR=$(which nvim)
export VISUAL="$EDITOR"

# Colorful sudo prompt.
export SUDO_PROMPT="$(tput setaf 2 bold)Password: $(tput sgr0)"

# FZF configuration.
export FZF_DEFAULT_COMMAND="fd --type file"
export FZF_DEFAULT_OPTS="--height 40% --layout reverse --border --preview 'bat --color=always --line-range :500 {}'"

# Ripgrep configuration.
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

bindkey "^[[Z" autosuggest-accept # shift + tab  | autosuggest
bindkey "^[[A" history-beginning-search-backward
bindkey "^P" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward
bindkey "^N" history-beginning-search-forward

alias c=clear
alias v="nvim"
alias lg="lazygit"
alias cd="\z"
alias ls="eza --icons"
alias ll="eza --icons -la"
alias lt="eza --icons --tree --level=2"
alias cat="bat"
alias config="nvim ~/.zshrc"
alias sysinfo="fastfetch"
alias trim-branches="git branch --merged | grep -v \* | xargs -n 1 git branch -d"
alias destroy-branches="git branch | grep -Ev 'master|develop' | xargs git branch -D"

function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
  command rm -f -- "$tmp"
}

function convertToMp4() {
  for arg in "$@"; do
    ffmpeg -i "$arg" -filter:v scale="trunc(oh*a/2)*2:720" -c:a copy "${arg%.*}".mp4
  done
}

function gd() {
  local dir=$(fd --type directory --hidden --follow --exclude .git --exclude node_modules . |
    fzf --preview 'eza --tree --level=2 --color=always {} | head -30')

  if [[ -d $dir ]]; then
    cd "$dir"
  else
    echo "No directory selected."
  fi
}

function vf() {
  fd --type file --hidden --follow --exclude .git --exclude node_modules . |
    fzf --preview 'bat --color=always --line-range :500 {}' --bind 'enter:become(nvim -- {})'
}

function vd() {
  fd --type directory --hidden --follow --exclude .git --exclude node_modules . |
    fzf --preview 'eza --tree --level=2 --color=always {} | head -30' --bind 'enter:become(nvim -- {})'
}

function kill-port() {
  local port=$1

  if [[ -z $port ]]; then
    echo "Usage: killport <port>"
    return 1
  fi

  local pid=$(lsof -t -i:$port)

  if [[ -n $pid ]]; then
    kill -9 $pid
    echo "Killed process on port $port (PID: $pid)"
  else
    echo "No process found on port $port"
  fi
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source ~/powerlevel10k/powerlevel10k.zsh-theme
