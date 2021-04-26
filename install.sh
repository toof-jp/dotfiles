#!/bin/sh
ln -sf ${PWD}/.zshrc ~/.zshrc
mkdir -p ~/.config
ln -sf ${PWD}/.config/git ~/.config
ln -sf ${PWD}/.config/nvim ~/.config
ln -sf ${PWD}/.config/tmux ~/.config
