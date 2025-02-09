# Check if eza exists and alias ls to eza
if type -q eza
    alias ls="eza"
end
alias la="ls -AlH" # Show hidden files, detailed listing
alias ll="ls -lH" # Detailed listing
alias lt="ls --tree" # Display directory as a tree
alias ld="ls -ld */" # List only directories

alias lg="lazygit"

# Check if zoxide exists and alias cd to zoxide
if type -q zoxide
    alias cd="z"
    alias zi="z -i" # Interactive mode for zoxide
    alias zb="z -b" # Jump to the best match
end

# Check if bat exists and alias cat to bat
if type -q bat
    alias cat="bat --style=plain --paging=never"
    alias batn="bat --style=numbers" # Bat with line numbers
    alias batc="bat --style=changes" # Bat with Git diff highlights
end

# Directory navigation aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../../"

# Editor aliases
alias vim="nvim"
alias v="nvim"
alias edit="nvim"
alias e="nvim"

# Git aliases
alias gs="git status"

alias ga="git add"
alias gA="git add -A"

alias gr="git restore"
alias grs="git restore --staged"

alias gc="git commit -s"
alias gcm="git commit -s -m"

alias gP="git push"
alias gPf="git push --force-with-lease"
alias gPF="git push --force"

alias gp="git pull"
alias gpr="git pull --rebase"

alias gck="git checkout"
alias gsw="git switch"

alias gl="git log --oneline --graph --decorate"
alias glo="git log --oneline"

alias gb="git branch"
alias gba="git branch -a"

alias gcp="git cherry-pick"
alias gcpn="git cherry-pick -n"

alias gwa="git worktree add"
alias gwr="git worktree remove"
alias gwls="git worktree list"
### End of git aliases 

# File search and manipulation aliases
alias f="find . -type f -iname"
alias grep="grep --color=auto"

# System monitoring aliases
alias dfh="df -h" # Disk usage in human-readable format
alias duh="du -sh" # Directory size in human-readable format
alias top="htop" # Use htop if installed
alias meminfo="free -h" # Memory usage

# Networking aliases
alias ip="ip -c a"
alias ping="ping -c 5"
alias ports="netstat -tulanp"
