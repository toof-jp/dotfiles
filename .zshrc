export LANG=en_US.UTF-8
export XDG_CONFIG_HOME="$HOME/.config"
export PATH=$HOME/.cargo/bin:$PATH
export EDITOR=nvim
# cursor path
export PATH=/mnt/c/Users/fmiya/AppData/Local/Programs/cursor/resources/app/bin:$PATH
export RUSTUP_TOOLCHAIN=nightly
source "$HOME/.cargo/env"
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"

# history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# keybind
bindkey -d
bindkey -e

# alias
alias c='claude'
alias cdp='c --dangerously-skip-permissions'
alias cat='bat'
alias g='git'
alias ga='git add -A'
alias gc='git commit -m "update"'
alias gs='git status'
alias gp='git push'
alias gacp='git add -A && git commit -m "update" && git push'
alias gl='git pull'
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
alias -g B="| echo '\a'"

# start cursor
function cu() {
  if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_TTY" ]; then
    # We're in an SSH session, use remote cursor
    local ssh_ip=$(echo $SSH_CONNECTION | cut -d' ' -f1)
    local local_ip=$(echo $SSH_CONNECTION | cut -d' ' -f3)
    ssh toof@$ssh_ip "/opt/homebrew/bin/cursor ssh-remote:toof@$local_ip \"$(pwd)\""
  else
    # Local session, use regular cursor
    cursor .
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

PROMPT='%F{red}%n@%m%f %F{yellow}%~%f
%# '

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
