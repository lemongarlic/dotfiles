if [[ $IS_MAC -eq 1 ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ $IS_LINUX -eq 1 ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

