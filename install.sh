#!/usr/bin/env bash
sudo -v

declare -a CONFIGS=(
  "macos"
  "zsh"
  "brew"
  "iterm2"
  "sublime"
  "keyboard"
)

for config in "${CONFIGS[@]}"
do
  echo "Installing $config"
  ./$config/install.sh
done

