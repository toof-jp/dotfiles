export LANG=en_US.UTF-8
export XDG_CONFIG_HOME="$HOME/.config"
export PATH=$HOME/.cargo/bin:$PATH
# cursor path
export PATH=/mnt/c/Users/user/AppData/Local/Programs/cursor/resources/app/bin:$PATH
export RUSTUP_TOOLCHAIN=nightly

# alias
alias c='cursor .'
alias cat='bat'
alias cg='cd $(ghq list -p | fzf)'
alias g='git'
alias ga='git add .'
alias gc='git commit -m "update"'
alias gs='git status'
alias gp='git push'
alias l='ls --color'
alias la='ls --color -a'
alias ll='ls --color -al'
alias v='nvim'
alias -g ...=../..
alias -g ....=../../..
alias -g .....=../../../..
alias -g L='| less'

# alias for WSL
if uname -r | grep -iq 'microsoft'; then
  alias open='explorer.exe'
  alias pbcopy='win32yank.exe -i'
  alias pbpaste='win32yank.exe -o --lf'
fi

# tmux
[[ -z "$TMUX" && ! -z "$PS1" ]] && tmux

PROMPT='%F{yellow}%~%f
> '

. "$HOME/.cargo/env"
