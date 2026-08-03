all: zsh git tmux ssh neovim cargo rustfmt claude codex krew herdr

zsh:
	mkdir -p ${HOME}/.zsh
	mkdir -p ${HOME}/.config
	curl -o ${HOME}/.zsh/git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
	ln -sf ${PWD}/.zshrc ${HOME}/.zshrc
	ln -sf ${PWD}/.zshrc.secret ${HOME}/.zshrc.secret
	ln -sf ${PWD}/.config/starship.toml ${HOME}/.config

git:
	mkdir -p ${HOME}/.config/git
	ln -sf ${PWD}/.config/git/config ${HOME}/.config/git
	ln -sf ${PWD}/.config/git/ignore ${HOME}/.config/git
	ln -sf ${PWD}/.config/git/allowed_signers ${HOME}/.config/git

# optional
gpg: git
	ln -sf ${PWD}/.config/git/gpg.config ${HOME}/.config/git/gpg.config

gnupg:
	mkdir -p ${HOME}/.gnupg
	ln -sf ${PWD}/.config/gnupg/gpg-agent.conf ${HOME}/.gnupg

tmux:
	mkdir -p ${HOME}/.config
	ln -sf ${PWD}/.config/tmux ${HOME}/.config

ssh:
	mkdir -p ${HOME}/.ssh
	ln -sf ${PWD}/.ssh/config ${HOME}/.ssh
	ln -sf ${PWD}/.ssh/config.mac ${HOME}/.ssh

neovim:
	mkdir -p ${HOME}/.config
	ln -sf ${PWD}/.config/lua-nvim ${HOME}/.config
	ln -sf ${PWD}/.config/nvim ${HOME}/.config

cargo:
	mkdir -p ${HOME}/.cargo
	ln -sf ${PWD}/.cargo/config.toml ${HOME}/.cargo

rustfmt:
	mkdir -p ${HOME}/.config
	ln -sf ${PWD}/.config/rustfmt ${HOME}/.config

claude:
	mkdir -p ${HOME}/.claude
	ln -sf ${PWD}/.config/claude/settings.json ${HOME}/.claude
	ln -sf ${PWD}/.config/claude/CLAUDE.md ${HOME}/.claude
	ln -sfn ${PWD}/.config/claude/skills ${HOME}/.claude/skills

codex:
	mkdir -p ${HOME}/.codex
	ln -sf ${PWD}/.codex/config.toml ${HOME}/.codex

krew:
	sh krew.sh

herdr:
	mkdir -p ${HOME}/.config/herdr
	ln -sf ${PWD}/.config/herdr/config.toml ${HOME}/.config/herdr

mac:
	mkdir -p ${HOME}/.ssh
	ln -sf ${PWD}/.ssh/config.mac ${HOME}/.ssh

.PHONY: all zsh git tmux ssh neovim cargo rustfmt claude codex krew herdr gpg gnupg
