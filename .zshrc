
for file in ~/.dotfiles/.{aliases,functions}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

HISTORY_IGNORE="(ls|cd|pwd|exit|cd ..|..)"
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_SAVE_NO_DUPS

export LANG=en_US.UTF-8
export PATH=$PATH:"/Applications/Sublime Merge.app/Contents/SharedSupport/bin"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"