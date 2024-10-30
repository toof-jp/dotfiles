all: zsh git tmux ssh neovim rustfmt

zsh:
	ln -sf ${PWD}/.zshrc ${HOME}/.zshrc

git:
	mkdir -p ${HOME}/.config
	ln -sf ${PWD}/.config/git ~/.config

tmux:
	mkdir -p ${HOME}/.config
	ln -sf ${PWD}/.config/tmux ~/.config

ssh:
	ln -sf ${PWD}/.ssh/config ~/.ssh

neovim:
	mkdir -p ${HOME}/.config
	ln -sf ${PWD}/.config/nvim ~/.config

rustfmt:
	mkdir -p ${HOME}/.config
	ln -sf ${PWD}/.config/rustfmt ~/.config

.PHONY: all zsh git tmux ssh neovim rustfmt
