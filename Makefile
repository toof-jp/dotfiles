all: zsh git tmux ssh neovim cargo rustfmt

zsh:
	ln -sf ${PWD}/.zshrc ${HOME}/.zshrc
	ln -sf ${PWD}/.zshrc.secret ${HOME}/.zshrc.secret

git:
	mkdir -p ${HOME}/.config
	ln -sf ${PWD}/.config/git ~/.config

tmux:
	mkdir -p ${HOME}/.config
	ln -sf ${PWD}/.config/tmux ~/.config

ssh:
	mkdir -p ${HOME}/.ssh
	ln -sf ${PWD}/.ssh/config ~/.ssh

neovim:
	mkdir -p ${HOME}/.config
	ln -sf ${PWD}/.config/nvim ~/.config

cargo:
	mkdir -p ${HOME}/.cargo
	ln -sf ${PWD}/.cargo/config.toml ~/.cargo

rustfmt:
	mkdir -p ${HOME}/.config
	ln -sf ${PWD}/.config/rustfmt ~/.config

.PHONY: all zsh git tmux ssh neovim cargo rustfmt
