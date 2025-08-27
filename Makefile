all: zsh git tmux ssh neovim cargo rustfmt claude krew

zsh:
	mkdir -p ~/.zsh
	curl -o ~/.zsh/git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
	ln -sf ${PWD}/.zshrc ${HOME}/.zshrc
	ln -sf ${PWD}/.zshrc.secret ${HOME}/.zshrc.secret

git:
	mkdir -p ${HOME}/.config
	ln -sf ${PWD}/.config/git ${HOME}/.config

tmux:
	mkdir -p ${HOME}/.config
	ln -sf ${PWD}/.config/tmux ${HOME}/.config

ssh:
	mkdir -p ${HOME}/.ssh
	ln -sf ${PWD}/.ssh/config ${HOME}/.ssh

neovim:
	mkdir -p ${HOME}/.config
	ln -sf ${PWD}/.config/nvim ${HOME}/.config

cargo:
	mkdir -p ${HOME}/.cargo
	ln -sf ${PWD}/.cargo/config.toml ${HOME}/.cargo

rustfmt:
	mkdir -p ${HOME}/.config
	ln -sf ${PWD}/.config/rustfmt ${HOME}/.config

claude:
	mkdir -p ${HOME}/.config
	mkdir -p ${HOME}/.config/claude
	ln -sf ${PWD}/.config/claude/settings.json ${HOME}/.config/claude

krew:
	sh krew.sh

.PHONY: all zsh git tmux ssh neovim cargo rustfmt claude krew
