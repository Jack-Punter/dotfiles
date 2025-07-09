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
# Standard and bright color variables
BLACK='\[\033[0;30m\]'
RED='\[\033[0;31m\]'
GREEN='\[\033[0;32m\]'
YELLOW='\[\033[0;33m\]'
BLUE='\[\033[0;34m\]'
MAGENTA='\[\033[0;35m\]'
CYAN='\[\033[0;36m\]'
WHITE='\[\033[0;37m\]'

BRIGHT_BLACK='\[\033[1;30m\]'
BRIGHT_RED='\[\033[1;31m\]'
BRIGHT_GREEN='\[\033[1;32m\]'
BRIGHT_YELLOW='\[\033[1;33m\]'
BRIGHT_BLUE='\[\033[1;34m\]'
BRIGHT_MAGENTA='\[\033[1;35m\]'
BRIGHT_CYAN='\[\033[1;36m\]'
BRIGHT_WHITE='\[\033[1;37m\]'

RESET='\[\033[00m\]'

# Function to set PS1 with customizable user@hostname color
set_git_prompt() {
    local user_color="${1:-$GREEN}"  # Default to GREEN if not specified

    PS1='${debian_chroot:+($debian_chroot)}'      # Show chroot if present
    PS1+="${user_color}\u@\h${RESET}:"            # user@hostname with custom color
    PS1+="${BRIGHT_BLUE}\w${RESET}"                      # Working directory
    PS1+="${RED}\$(__git_ps1 \" (%s)\")${RESET}"  # git branch info
    PS1+='\n ↳ '                                  # New line with arrow prompt
    export PS1
}

# Example usage:
set_git_prompt "$BRIGHT_GREEN"
