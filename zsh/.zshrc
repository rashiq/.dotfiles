
export PATH="~/Library/Python/2.7/bin:$PATH"

export ZSH="/Users/rashiq/.oh-my-zsh"
export BAT_PAGER="less -F"



ZSH_THEME="rashiq"
plugins=(
  git,
  zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh


alias airport="macchanger -r en0"
alias l="exa -la"
alias ls="exa"
alias cat="bat"