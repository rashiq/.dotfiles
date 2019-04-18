alias airport="macchanger -r en0"
alias l="exa -la"
alias ls="exa"
alias brewfile="subl -n ~/.dotfiles/brew/Brewfile"

# Create a gif
movToGif() {
  ffmpeg -i $1 -pix_fmt rgb24 -r 24 -f gif - | gifsicle --optimize=2 > $2
}
