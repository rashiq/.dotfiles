
ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="rashiq"
plugins=(
  git
  zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

source ~/.dotfiles/zsh/env.sh

source ~/.dotfiles/zsh/alias.sh

source $(brew --prefix autoenv)/activate.sh