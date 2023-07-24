
export LANG=en_US.UTF-8
export PATH=$PATH:"/Applications/Sublime Merge.app/Contents/SharedSupport/bin"
export PATH=$PATH:"/Applications/Sublime Text.app/Contents/SharedSupport/bin"
export PATH="/usr/local/opt/libpq/bin:$PATH"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
export PATH="$PATH:/opt/homebrew/opt/libpq/bin"
export PATH="$PATH:$HOME/.ai"

# android dev
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
# ruby version mananger (needed for RN)
eval "$(rbenv init - zsh)"

HISTORY_IGNORE="(ls|cd|pwd|exit|cd ..|..)"
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_SAVE_NO_DUPS

# PROMPT with git branch name
autoload -Uz vcs_info
precmd() {vcs_info}
setopt PROMPT_SUBST
# add \n for newline
#zstyle ':vcs_info:git:*' formats '%b '
#PROMPT=$'%F{242}${vcs_info_msg_0_}%f%F{222}%~%f %F{reset_color}'
zstyle ':vcs_info:git:*' formats ' %b'
PROMPT=$'%F{82}%~%f%F{222}${vcs_info_msg_0_}%f %F{reset_color}'

# tab completion
autoload -Uz compinit && compinit

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

export ZSHZ_CMD=f
export ZSHZ_DATA="$HOME/.zsh/.z"
source ~/.zsh/z.sh

export EDITOR='code'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND="rg --files --hidden -uuu --glob '!**/node_modules/*' --glob '!**/Pods/*'" # 'rg --files --hidden'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

for file in ~/dotfiles/{aliases.sh,functions.sh}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;