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

# plugin
#source ~/.zplug/init.zsh
#
#zplug "zsh-users/zsh-syntax-highlighting", defer:3
#
#if ! zplug check --verbose; then
#    printf "Install? [y/N]: 
#    if read -q; then
#        echo; zplug install
#    fi
#fi
#
#zplug load --verbose
