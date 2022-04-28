
export LANG=en_US.UTF-8
export PATH=$PATH:"/Applications/Sublime Merge.app/Contents/SharedSupport/bin"
export PATH="/usr/local/opt/libpq/bin:$PATH"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

for file in ~/.dotfiles/.{aliases,functions}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

HISTORY_IGNORE="(ls|cd|pwd|exit|cd ..|..)"
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_SAVE_NO_DUPS

# PROMPT with git branch name
autoload -Uz vcs_info
precmd() {vcs_info}
zstyle ':vcs_info:git:*' formats '%b '
setopt PROMPT_SUBST
# add \n for newline
PROMPT=$'%F{242}${vcs_info_msg_0_}%f%F{222}%~%f %F{reset_color}'

# tab completion
autoload -Uz compinit && compinit

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

export _Z_CMD=f
export _Z_DATA="$HOME/.zsh/.z"
source ~/.zsh/z/z.sh

export EDITOR='vim'