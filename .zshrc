# path
export XDG_CONFIG_HOME="$HOME/.config"

# alias
alias sl='ls'
alias ls='ls -G'
alias lsa='ls -a'
alias v='nvim'

# tmux
[[ -z "$TMUX" && ! -z "$PS1" ]] && tmux

# rbenv
[[ -d ~/.rbenv  ]] && \
  export PATH=${HOME}/.rbenv/bin:${PATH} && \
  eval "$(rbenv init -)"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# plugin
source ~/.zplug/init.zsh

zplug "zsh-users/zsh-syntax-highlighting", defer:3

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load --verbose
