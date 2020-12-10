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
alias -g ...=../..
alias -g ....=../../..
alias -g .....=../../../..

# alias for WSL
if uname -r | grep -iq 'microsoft'; then
  alias pbcopy='win32yank.exe -i'
  alias pbpaste='win32yank.exe -o --lf'
  alias open='explorer.exe'
fi

# tmux
[[ -z "$TMUX" && ! -z "$PS1" ]] && tmux

PROMPT='%F{yellow}%~%f
> '
