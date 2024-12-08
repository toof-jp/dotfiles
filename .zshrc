export LANG=en_US.UTF-8
export XDG_CONFIG_HOME="$HOME/.config"
export PATH=$HOME/.cargo/bin:$PATH
export EDITOR=nvim
# cursor path
export PATH=/mnt/c/Users/user/AppData/Local/Programs/cursor/resources/app/bin:$PATH
export RUSTUP_TOOLCHAIN=nightly
source "$HOME/.cargo/env"

# history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# keybind
bindkey -d
bindkey -e

# alias
alias c='cursor .'
alias cat='bat'
alias g='git'
alias ga='git add .'
alias gc='git commit -m "update"'
alias gs='git status'
alias gp='git push'
alias l='ls --color'
alias la='ls --color -a'
alias ll='ls --color -al'
alias v='nvim'
alias toof='cd ~/ghq/github.com/toof-jp'
alias vps='~/vps.sh'
alias -g ...=../..
alias -g ....=../../..
alias -g .....=../../../..
alias -g L='| less'

# ghq list and cd
function cg() {
  local selected
  if [ "$#" -eq 0 ]; then
    selected=$(ghq list | fzf)
  else
    selected=$(ghq list | fzf --select-1 --query="$1")
  fi
  [ -n "$selected" ] && cd "$(ghq root)/$selected"
}

# secret config
ZSH_SECRET_CONF="${HOME}/.zshrc.secret"

if [ -e "${ZSH_SECRET_CONF}" ]; then
  source "${ZSH_SECRET_CONF}"
fi

# alias for WSL
if uname -r | grep -iq 'microsoft'; then
  export BROWSER=wsl-open
  alias open='wsl-open'
  alias pbcopy='win32yank.exe -i'
  alias pbpaste='win32yank.exe -o --lf'
fi

# start tmux
[[ -z "$TMUX" && ! -z "$PS1" && $TERM_RPOGRAM != "vscode" ]] && tmux

PROMPT='%F{yellow}%~%f
> '
