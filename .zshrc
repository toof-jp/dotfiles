export LANG=en_US.UTF-8
export XDG_CONFIG_HOME="$HOME/.config"
export PATH=$HOME/.cargo/bin:$PATH
export EDITOR=nvim
# cursor path
export PATH=/mnt/c/Users/fmiya/AppData/Local/Programs/cursor/resources/app/bin:$PATH
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
## new repo
alias nr='cd ~/ghq/github.com/toof-jp && gh repo create' 
alias vps='ssh $(cat ~/vps-user-and-fqdn)'
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

# ghq clone
function cl() {
  if [ "$#" -eq 0 ]; then
    echo "Usage: cl <repository-url>"
    return 1
  fi
  ghq clone $1
}

# secret config
ZSH_SECRET_CONF="${HOME}/.zshrc.secret"

if [ -e "${ZSH_SECRET_CONF}" ]; then
  source "${ZSH_SECRET_CONF}"
fi

# alias for WSL
if uname -r | grep -iq 'microsoft'; then
  export WSL_DISTRO_NAME=Arch
  export BROWSER=wsl-open
  alias open='wsl-open'
  alias pbcopy='win32yank.exe -i'
  alias pbpaste='win32yank.exe -o --lf'
fi

# start tmux
[[ -z "$TMUX" && ! -z "$PS1" && $TERM_RPOGRAM != "vscode" ]] && tmux

PROMPT='%F{yellow}%~%f
> '

env=~/.ssh/agent.env

agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ; }

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add
fi

unset env
