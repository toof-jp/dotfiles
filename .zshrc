export LANG=en_US.UTF-8
export XDG_CONFIG_HOME="$HOME/.config"
export PATH=$PATH:/home/toof/.local/bin

# alias
alias l='ls --color'
alias la='ls --color -a'
alias v='nvim'
alias cat='bat'
alias g='git'
alias gs='git status'
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
