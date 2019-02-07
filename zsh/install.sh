#!/usr/bin/env bash

ZSHRC_FILE=~/.zshrc
ln -sf ~/.dotfiles/zsh/.zshrc $ZSHRC_FILE

ZSH_THEME_DIR=~/.oh-my-zsh/custom/themes/
mkdir -p $ZSH_THEME_DIR
ln -sf ~/.dotfiles/zsh/rashiq.zsh-theme $ZSH_THEME_DIR