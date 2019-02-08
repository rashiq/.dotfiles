#!/usr/bin/env bash
sudo -v

declare -a CONFIGS=(
  "macos"
  "zsh"
  "brew"
  "iterm2"
  "sublime"
)

for config in "${CONFIGS[@]}"
do
  echo "Installing $config"
  ./$config/install.sh
  break
done

