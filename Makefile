all: zsh git tmux ssh neovim

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

.PHONY: all zsh git tmux neovim
