# variables
export EDITOR="nvr"
export BUN_INSTALL="$HOME/.bun"

## tmux
export IS_TMUX_REMOTE=0
[[ -n "$SSH_CLIENT" ]] && export IS_TMUX_REMOTE=1

## windows
export IS_WSL=0
[[ -e /proc/sys/fs/binfmt_misc/WSLInterop ]] && export IS_WSL=1

## mac
export IS_MAC=0
[[ $(uname) == 'Darwin' ]] && export IS_MAC=1

## linux
export IS_LINUX=0
export IS_ARCH_LINUX=0
if [[ $(uname) == 'Linux' ]]; then
  export IS_LINUX=1
  [[ $(uname -r) == *arch* ]] && export IS_ARCH_LINUX=1
fi

## path
export PATH="$HOME/.config/composer/vendor/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$BUN_INSTALL/bin:$PATH"
if [[ $IS_WSL -eq 1 ]]; then
  export PATH="/home/linuxbrew/.linuxbrew/opt/uutils-coreutils/libexec/uubin:$PATH"
  export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
elif [[ $IS_MAC -eq 1 ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
  export PATH="/opt/homebrew/opt/uutils-coreutils/libexec/uubin:$PATH"
  export PATH="$HOME/Library/Android/sdk/tools:$PATH"
  export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
fi

