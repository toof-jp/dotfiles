export LANG=en_US.UTF-8
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR=nvim
export RUSTUP_TOOLCHAIN=nightly
export GPG_TTY=$(tty)
# history
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000

# PATH
export PATH=$HOME/.cargo/bin:$PATH
export PATH=/mnt/c/Users/fmiya/AppData/Local/Programs/cursor/resources/app/bin:$PATH
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# keybind
bindkey -d
bindkey -e

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# alias
alias c='claude'
alias cdp='c --dangerously-skip-permissions'
alias ca='cargo'
alias cat='bat'
alias g='git'
alias ga='git add -A'
function gc() {
  git commit -m "$*"
}
alias gu='git commit -m "update"'
alias s='git status'
alias gs='git switch'
alias GS='git stash'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gr='git restore'
alias grs='git reset --soft HEAD^'
alias gacp='git add -A && git commit -m "update" && git push'
alias GP='git pull'
alias gl='git log'
alias gd='git diff'
alias gb='git branch'
alias l='ls --color'
alias la='ls --color -a'
alias ll='ls --color -al'
alias v='nvim'
alias rm='gomi'
alias kc='kubectl'
alias toof='cd ~/ghq/github.com/toof-jp'
## new repo
alias nr='cd ~/ghq/github.com/toof-jp && gh repo create' 
alias vps='ssh $(cat ~/vps-user-and-fqdn)'
alias tree='tree --gitignore'
alias capture-pane='tmux capture-pane -pS -'
alias card='gpg --card-status'
alias port='ss -tulpn'
alias -g ...=../..
alias -g ....=../../..
alias -g .....=../../../..
alias -g L='| less'
alias -g B="| echo '\a'"

# start cursor
function cu() {
  if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_TTY" ]; then
    # We're in an SSH session, use remote cursor
    local ssh_ip=$(echo $SSH_CONNECTION | cut -d' ' -f1)
    ssh toof@$ssh_ip "/opt/homebrew/bin/cursor --remote ssh-remote+toof@$HOST \"$(pwd)\""
  else
    # Local session, use regular cursor
    cursor .
  fi
}

# start code
function co() {
  if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_TTY" ]; then
    # We're in an SSH session, use remote code
    local ssh_ip=$(echo $SSH_CONNECTION | cut -d' ' -f1)
    ssh toof@$ssh_ip "/opt/homebrew/bin/code --remote ssh-remote+toof@$HOST \"$(pwd)\""
  else
    # Local session, use regular code
    code .
  fi
}

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

function repo() {
  local root_path=$(git rev-parse --show-toplevel)
  [ -n "$root_path" ] && cd $root_path
}

# ghq clone
function cl() {
  if [ "$#" -eq 0 ]; then
    echo "Usage: cl <repository-url>"
    return 1
  fi
  ghq clone $1
}

# Python HTTP server
function serve() {
  local port=${1:-8000}
  python -m http.server $port
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
[[ -z "$TMUX" && ! -z "$PS1" && "$TERM_PROGRAM" != "vscode" && "$TERM_PROGRAM" != "WarpTerminal" ]] && tmux

# prompt
source ~/.zsh/git-prompt.sh

GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUPSTREAM=auto

DEMOSH_TOGGLE=0
# toggle prompt to copy shell
function demosh() {
  if [[ $DEMOSH_TOGGLE -eq 0 ]] then
    eval "$(starship init zsh)"
  else
    PROMPT='%F{cyan}$%f '
    RPROMPT=''
  fi

  (( DEMOSH_TOGGLE ^= 1 ))
}
demosh

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

# GPG
export GPG_TTY=$(tty)
gpgconf --launch gpg-agent
export GPG_TTY=$(tty)

# kubectl
autoload -Uz compinit
compinit
source <(kubectl completion zsh)

eval "$(mise activate zsh)"
