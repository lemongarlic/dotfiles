# settings
## vi mode
bindkey -v
export KEYTIMEOUT=1

## cli edit
autoload edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey -M vicmd '^e' edit-command-line

## autocomplete
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)

## history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY




# commands
bindkey '^K' vi-cmd-mode



# aliases
alias e='editor'
alias p='pueue'
alias pd='pueue remove'
alias pa='pueue add'
alias pga='pueue group add'
alias pgd='pueue group remove'
alias pp='pueue parallel'
alias rl='source ~/.zshrc'
alias in='tmux-in'
alias out='tmux-out'
alias td='tmux-delete'
alias tk='tmux-kill'
alias tka='tmux-kill-all'
alias tl='ls /tmp/tmux-*'
alias tn="tmux display-message -p '#S'"
alias phpv='switch-php-version'

if [[ $IS_ARCH_LINUX -eq 1 ]]; then
  alias pac='yay -S --noconfirm --answeredit No'
  alias unpac='sudo pacman -Rns --noconfirm'
fi



# functions
## neovim
editor() {
  if [[ -S /tmp/nvimsocket ]]; then
    nvr "$@"
  else
    nvim --listen /tmp/nvimsocket "$@"
  fi
}

## tmux
tmux-in() {
  local session_name=${1:-main}
  if tmux -L "$session_name" has-session -t "$session_name" 2>/dev/null; then
    tmux -L "$session_name" attach-session -t "$session_name"
  else
    if [[ "$session_name" == "main" ]]; then
      cd ~
      tmux -L "$session_name" new-session -d -s main -n vim 'rm -f /tmp/nvimsocket; zsh -c "nvim --listen /tmp/nvimsocket; zsh"'
      tmux -L "$session_name" select-window -t main:0
      tmux -L "$session_name" attach-session -t "$session_name"
    else
      tmux -L "$session_name" -f "$HOME/.tmux.nested.conf" new-session -d -s "$session_name" -n zsh 'zsh'
      tmux -L "$session_name" attach-session -t "$session_name"
    fi
  fi
}

tmux-out() {
  tmux info &>/dev/null && tmux detach || echo 'Not in a tmux session.'
}

tmux-delete() {
  local session_name=${1:-main}
  tmux -L "$session_name" kill-session -t "$session_name"
}

tmux-kill() {
  local session_name=${1:-main}
  tmux -L "$session_name" kill-session -t "$session_name"
  rm -f "/tmp/tmux-*/$session_name"
}

tmux-kill-all() {
  for file in /tmp/tmux-*/**/*; do
    [ -e "$file" ] || continue
    session_name=$(basename "$file")
    tmux -L "$session_name" kill-server
  done
}

## pueued
ensure-pueued-is-running() {
  pgrep pueued > /dev/null || pueued -d > /dev/null 2>&1
}

## php
switch-php-version() {
  if [[ $# -eq 0 ]]; then
    echo 'Usage: switch-php-version <version>'
    return 1
  fi
  local php_version="$1"
  local brew_php_path
  brew_php_path=$(brew --prefix php@"$php_version")
  if [[ ! -d "$brew_php_path" ]]; then
    echo "PHP $php_version not installed. Installing..."
    brew install php@"$php_version"
  fi
  echo "Switching to PHP $php_version..."
  brew unlink php > /dev/null 2>&1
  brew link --force --overwrite php@"$php_version"
  php -v
}

## yadm
check-yadm-updates() {
  yadm fetch > /dev/null 2>&1
  local local_commit remote_commit
  local_commit=$(yadm rev-parse @)
  remote_commit=$(yadm rev-parse @{u})
  [[ "$local_commit" != "$remote_commit" ]] && echo "Your yadm repo is not up-to-date with the remote. Run 'yadm pull' to sync."
}

## yt-dlp
play() {
  if [[ $IS_WSL -eq 1 ]]; then
    if [[ ! -e /mnt/e/app/mpv/mpv.exe ]]; then
      echo 'Error: mpv.exe is not installed or not in PATH'
      return 1
    fi
    if ! command -v yt-dlp &>/dev/null; then
      echo 'Error: yt-dlp is not installed or not in PATH'
      return 1
    fi
    local url="$1"
    local name file
    name=$(yt-dlp --no-warnings --get-title "$url")
    file="/tmp/$name.mp4"
    [[ ! -e "$file" ]] && yt-dlp --progress --no-warnings --quiet -o "$file" "$url"
    nohup /mnt/e/app/mpv/mpv.exe "$file" &>/dev/null &
  fi
}



# init
check-yadm-updates
ensure-pueued-is-running
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2>/dev/null


# bun completions
[ -s "/Users/user/.bun/_bun" ] && source "/Users/user/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
