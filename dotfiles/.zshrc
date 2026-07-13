export PATH="/usr/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
# function to show current git branch and status in the prompt
git_info() {
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
      echo " %F{green}‹${branch}%f %F{red}|!|%f%F{green}›%f"
    else
      echo " %F{green}‹${branch}›%f"
    fi
  fi
}

# enable command output inside prompt
setopt PROMPT_SUBST

# prompt
PROMPT='%F{blue}%B%~%b%f$(git_info) [%*]
%B%(!.#.$)%b '

# completion
autoload -Uz compinit
compinit

# colors
autoload -U colors && colors
export LS_COLORS="di=1;34"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select=1

# history
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

#LM studio
alias ai="/home/faraz/Desktop/LMStudio.AppImage"
alias win="/home/faraz/Applications/Winboat.AppImage"
# yay
alias yeet="yay -Rn"
alias ls='ls -h --color=auto'
alias nv="nvim"
alias start="start-hyprland"

alias dotter="/home/faraz/dotterfiles/backup.sh"
alias cmt="git commit -a && git push"
alias snv="sudo nvim"
alias ssd="cd /mnt/SSD"
alias hdd='cd /mnt/HDD'
alias mnt="sudo mount"
alias ani="ani-cli"

fastfetch
alias vpnu="sudo wg-quick up aloo"
alias vpnd="sudo wg-quick down aloo"
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/faraz/.lmstudio/bin"
# End of LM Studio CLI section

