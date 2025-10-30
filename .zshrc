
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
# eval "$(rbenv init - zsh)"

bindkey -e  # Emacs key bindings
bindkey "^[[1;3C" forward-word      # Option+Right
bindkey "^[[1;3D" backward-word     # Option+Left

# require pressing ctrl+d 2 times to exit shell
export IGNOREEOF=2

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
PROMPT=$'%F{141}%~%f%F{222}${vcs_info_msg_0_}%f %F{reset_color}' # purple:141 green:82

# tab completion
autoload -Uz compinit && compinit

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}'

# export ZSHZ_CMD=f
# export ZSHZ_DATA="$HOME/.zsh/.z"
# source ~/.zsh/z.sh

export EDITOR='nvim'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND="rg --files --hidden -uuu --glob '!**/node_modules/*' --glob '!**/Pods/*' --glob '!**/.git/*' --glob '!**/.next/*'" # 'rg --files --hidden'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

for file in ~/dev/dotfiles/{aliases.sh,functions.sh}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

unset _VOLTA_TOOL_RECURSION # https://github.com/volta-cli/volta/issues/1007#issuecomment-881771029

# emoves all previous occurrences of a command before adding the latest one, ensuring each unique command is stored only once.
setopt HIST_IGNORE_ALL_DUPS
# prevents consecutive duplicate commands from being saved in the history.
setopt HIST_IGNORE_DUPS

# 🚨 also check detach-on-destroy in tmux.conf !!!
# attach to main session if not in vscode when starting a new terminal
# if [[ "$TERM_PROGRAM" != "vscode" ]]; then
#   if [ -z "$TMUX" ]; then 
#     # Don't auto-attach if we just exited a tmux session (like from a popup)
#     if [ -z "$TMUX_POPUP" ]; then
#       tmux attach -t main || tmux new -s main
#     fi
#   fi
# fi

eval "$(zoxide init zsh --cmd cd)"

. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh --disable-up-arrow)"
