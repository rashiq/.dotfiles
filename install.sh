#!/usr/bin/env bash
sudo -v

declare -a CONFIGS=(
  "macos"
  "keyboard"
  "zsh"
  "iterm2"
  "brew"
  "sublime"
)

for config in "${CONFIGS[@]}"
do
  echo "Installing $config"
  ./$config/install.sh
done

