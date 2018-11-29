
## NVM (node version manager. Install with brew)

# NVM default setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# lazy setup nvm
# lazynvm() {
#   unset -f nvm node npm npx ionic #ADD_NEW_GLOBAL_PACKAGES HERE#
#   export NVM_DIR=~/.nvm
#   [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
# 	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# }

# nvm() { lazynvm nvm $@ }
# node() { lazynvm node $@ }
# npm() { lazynvm npm $@ }
# npx() { lazynvm npx $@ }
# ionic() { lazynvm ionic $@ }
#ADD_NEW_GLOBAL_PACKAGES HERE#

## /NVM


# Load the shell dotfiles:
for file in ~/.{aliases,functions}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;


export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/emulator
export LANG=en_US.UTF-8
