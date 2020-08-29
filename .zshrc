# path
export XDG_CONFIG_HOME="$HOME/.config"

# alias
alias sl='ls --color'
alias ls='ls --color'
alias lsa='ls --color -a'
alias v='nvim'
alias pwdcp='pwd | pbcopy'

# tmux
[[ -z "$TMUX" && ! -z "$PS1" ]] && tmux

cd
