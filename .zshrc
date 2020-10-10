export LANG=en_US.UTF-8

#path
export XDG_CONFIG_HOME="$HOME/.config"
export PATH=$PATH:/home/toof/.local/bin

# alias
alias sl='ls --color'
alias ls='ls --color'
alias la='ls --color -a'
alias v='nvim'
alias e='nvim'
alias g='git'

# tmux
[[ -z "$TMUX" && ! -z "$PS1" ]] && tmux

PROMPT='%F{yellow}%~%f
> '

cd
