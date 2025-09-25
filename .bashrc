#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias mnthdd='sudo mount /dev/sda1 /mnt/HDD'
alias Hdd='cd /mnt/HDD'
alias ani='ani-cli'
alias nv='nvim'
alias snv='sudo nvim'
alias umthdd='sudo umount /mnt/HDD'
alias mst='ollama run mistral:7b'
alias solar='ollama run sushruth/solar-uncensored:latest'
alias daredevil='ollama run closex/neuraldaredevil-8b-abliterated:Q6_K'
PS1='[\u@\h \W]\$ '



neofetch




export MANPAGER='nvim +Man!'
