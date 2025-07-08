mkdir -p ~/.config/jack-punter/git-prompt

# Download necessary git shell sources if they dont exist
if [ ! -f ~/.config/jack-punter/git-prompt/git-completion.bash ]; then
    curl -s https://raw.githubusercontent.com/git/git/refs/heads/master/contrib/completion/git-completion.bash \
        -o ~/.config/jack-punter/git-prompt/git-completion.bash
fi
if [ ! -f ~/.config/jack-punter/git-prompt/git-prompt.sh ]; then
    curl -s https://raw.githubusercontent.com/git/git/refs/heads/master/contrib/completion/git-prompt.sh \
        -o ~/.config/jack-punter/git-prompt/git-prompt.sh
fi

# Source the files
source ~/.config/jack-punter/git-prompt/git-completion.bash
source ~/.config/jack-punter/git-prompt/git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1

# Define color variables for cleaner code
GREEN='\[\033[01;32m\]'
BLUE='\[\033[01;34m\]'
RED='\[\033[0;91m\]'
RESET='\[\033[00m\]'

# Build the prompt components
# Format: [chroot]user@host:directory (git_branch) 
#          ↳
PS1='${debian_chroot:+($debian_chroot)}'      # Show chroot if present
PS1+="${GREEN}\u@\h${RESET}:"                 # user@hostname:
PS1+="${BLUE}\w${RESET}"                      # Working directory
PS1+="${RED}\$(__git_ps1 \" (%s)\")${RESET}"  # git branch info
PS1+='\n ↳ '                                  # New line with arrow prompt
export PS1
