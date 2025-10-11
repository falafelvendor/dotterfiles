ZSH="/usr/share/oh-my-zsh/"
export ZSH="/usr/share/oh-my-zsh/"
ZSH_THEME="keyitdev"
plugins=(git)

ZSH_CACHE_DIR="$HOME/.cache/oh-my-zsh"
if [[ ! -d "$ZSH_CACHE_DIR" ]]; then
  mkdir "$ZSH_CACHE_DIR"
fi

source "$ZSH"/oh-my-zsh.sh


alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias mnthdd='sudo mount /dev/sda1 /mnt/HDD'
alias Hdd='cd /mnt/HDD'
alias ani='ani-cli'
alias nv='nvim'
alias snv='sudo nvim'
alias umthdd='sudo umount /mnt/HDD'
alias mst='ollama run mistral:7b'
alias byeee='echo "powering off" && sleep 3 && poweroff'
alias lock='i3lock'
# cd
alias ..="cd .."
alias ....="cd ../.."
alias ......="cd ../../.."
alias ........="cd ../../../.."



neofetch
