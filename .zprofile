if [[ $IS_MAC -eq 1 ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ $IS_LINUX -eq 1 ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  if [[ $IS_WSL -eq 0 ]]; then
    [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
  fi
fi

